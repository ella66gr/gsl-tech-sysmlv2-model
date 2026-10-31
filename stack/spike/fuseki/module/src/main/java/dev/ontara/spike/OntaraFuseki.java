// OP-134 spike, configuration 3: Apache Jena Fuseki with a minimal module that
// runs each SPARQL Update request inside jena-shacl's GraphValidation.update,
// so a violating update aborts its transaction.
//
// Two TDB2 datasets, fixed at start: /cafe-runtime and /cafe-capability-scratch.
// Each has Fuseki's standard endpoints (query, update, data = Graph Store
// Protocol), which do NOT validate, and the module's endpoint:
//   POST /{dataset}/validated-update   application/sparql-update
//        200  committed
//        422  SHACL rejection: the validation report as N-Triples
//             (Content-Type application/shacl-validation-report+n-triples);
//             the TDB2 write transaction was aborted
//        400  the request does not parse;  500 any other fault (aborted)
//   GET  /{dataset}/validated-update   JSON status
//
// Shapes are read from the dataset's named graph SHAPES_GRAPH
// (urn:ontara:stack:shapes) at the start of each request's write transaction.
// The data graph validated is the dataset's union graph (every named graph),
// and the default graph for queries and update WHERE clauses is that union
// (tdb2:unionDefaultGraph), as RDF4J and GraphDB behave.
package dev.ontara.spike;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;

import org.apache.jena.fuseki.main.FusekiServer;
import org.apache.jena.fuseki.server.Operation;
import org.apache.jena.fuseki.servlets.BaseActionREST;
import org.apache.jena.fuseki.servlets.HttpAction;
import org.apache.jena.graph.Graph;
import org.apache.jena.graph.NodeFactory;
import org.apache.jena.query.TxnType;
import org.apache.jena.riot.Lang;
import org.apache.jena.riot.RDFDataMgr;
import org.apache.jena.riot.WebContent;
import org.apache.jena.shacl.GraphValidation;
import org.apache.jena.shacl.Shapes;
import org.apache.jena.shacl.ValidationReport;
import org.apache.jena.sparql.core.DatasetGraph;
import org.apache.jena.sparql.graph.GraphFactory;
import org.apache.jena.tdb2.TDB2;
import org.apache.jena.tdb2.TDB2Factory;
import org.apache.jena.update.UpdateAction;
import org.apache.jena.update.UpdateFactory;
import org.apache.jena.update.UpdateRequest;

public class OntaraFuseki {
    static final String SHAPES_GRAPH = env("SHAPES_GRAPH", "urn:ontara:stack:shapes");
    static final String JENA_VERSION = env("JENA_VERSION", "unknown");

    static String env(String k, String d) { String v = System.getenv(k); return v == null || v.isEmpty() ? d : v; }

    public static void main(String... args) {
        String base = env("FUSEKI_DATA", "/fuseki/databases");
        int port = Integer.parseInt(env("FUSEKI_PORT", "3030"));
        Operation op = Operation.alloc("https://ontara.dev/spike/fuseki#validated-update", "validated-update",
                "SHACL-validated SPARQL Update (jena-shacl GraphValidation.update)");
        FusekiServer.Builder b = FusekiServer.create().port(port).registerOperation(op, WebContent.contentTypeSPARQLUpdate, new ValidatedUpdate());
        for (String name : List.of("cafe-runtime", "cafe-capability-scratch")) {
            DatasetGraph dsg = TDB2Factory.connectDataset(base + "/" + name).asDatasetGraph();
            dsg.getContext().set(TDB2.symUnionDefaultGraph, true);
            b.add("/" + name, dsg, true).addEndpoint("/" + name, "validated-update", op);
        }
        FusekiServer server = b.build();
        server.start();
        System.out.println("[ontara-fuseki] Jena " + JENA_VERSION + " on :" + port + ", shapes graph <" + SHAPES_GRAPH + ">");
        server.join();
    }

    static class ValidatedUpdate extends BaseActionREST {
        @Override
        protected void doGet(HttpAction action) {
            DatasetGraph dsg = action.getDataset();
            long shapes = dsg.calculateRead(() -> dsg.getGraph(NodeFactory.createURI(SHAPES_GRAPH)).size());
            String json = "{\"module\": \"ontara-fuseki-validated-update 0.1.0\", \"jenaVersion\": \"" + JENA_VERSION
                    + "\", \"fusekiVersion\": \"" + JENA_VERSION + "\", \"store\": \"TDB2\", \"unionDefaultGraph\": "
                    + dsg.getContext().isTrue(TDB2.symUnionDefaultGraph) + ", \"validating\": true, "
                    + "\"engine\": \"jena-shacl GraphValidation.update (whole union graph)\", \"shapesGraph\": \"" + SHAPES_GRAPH
                    + "\", \"shapesTriples\": " + shapes + ", \"inference\": \"none\"}";
            reply(action, 200, "application/json", json, null);
        }

        @Override
        protected void doPost(HttpAction action) {
            String body;
            try (InputStream in = action.getRequestInputStream()) {
                body = new String(in.readAllBytes(), StandardCharsets.UTF_8);
            } catch (IOException e) { reply(action, 500, "text/plain", "read: " + e, null); return; }
            UpdateRequest req;
            try { req = UpdateFactory.create(body); }
            catch (Exception e) { reply(action, 400, "text/plain", "parse: " + e.getMessage(), null); return; }

            DatasetGraph dsg = action.getDataset();
            dsg.begin(TxnType.WRITE);
            try {
                // Shapes: copied out of the shapes graph inside this transaction.
                Graph shapesGraph = GraphFactory.createDefaultGraph();
                dsg.getGraph(NodeFactory.createURI(SHAPES_GRAPH)).find().forEachRemaining(shapesGraph::add);
                Shapes shapes = Shapes.parse(shapesGraph);
                Graph data = dsg.getUnionGraph();
                // GraphValidation.update runs the update inside the graph's
                // transaction (here, the one just begun), validates the whole
                // graph, and throws ShaclValidationException if it does not
                // conform; updateAndReport returns that report instead.
                ValidationReport report = GraphValidation.updateAndReport(shapes, data, () -> UpdateAction.execute(req, dsg));
                if (report.conforms()) {
                    dsg.commit();
                    reply(action, 200, "application/json", "{\"outcome\": \"committed\"}", "committed");
                } else {
                    dsg.abort();
                    java.io.ByteArrayOutputStream out = new java.io.ByteArrayOutputStream();
                    RDFDataMgr.write(out, report.getGraph(), Lang.NTRIPLES);
                    reply(action, 422, "application/shacl-validation-report+n-triples", out.toString(StandardCharsets.UTF_8), "aborted");
                }
            } catch (Throwable e) {
                try { if (dsg.isInTransaction()) dsg.abort(); } catch (Throwable ignore) { }
                reply(action, 500, "text/plain", "fault: " + e, "aborted");
            } finally {
                if (dsg.isInTransaction()) dsg.end();
            }
        }

        static void reply(HttpAction action, int status, String type, String text, String txn) {
            action.setResponseStatus(status);
            action.setResponseContentType(type);
            if (txn != null) action.setResponseHeader("X-Ontara-Transaction", txn);
            try {
                OutputStream os = action.getResponseOutputStream();
                os.write(text.getBytes(StandardCharsets.UTF_8));
                os.flush();
            } catch (IOException e) { throw new RuntimeException(e); }
        }
    }
}
