// OP-134 spike, configuration 3: Apache Jena Fuseki with a minimal module that
// runs each SPARQL Update request inside one TDB2 write transaction and
// validates it with jena-shacl, so a violating update aborts its transaction.
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
// Response header X-Ontara-Validation says how the request was validated.
//
// Validation mode, set by ONTARA_VALIDATION (S519, OP-134 follow-up Part D):
//   whole     (default; the S518 behaviour, unchanged) jena-shacl
//             GraphValidation.updateAndReport: run the update, then validate
//             every shape against the whole union graph.
//   targeted  run the update through a recording wrapper, then validate only
//             the nodes the update touched (the subject and object of every
//             quad it added or deleted), each against every shape that targets
//             it (VLib.isFocusNode, VLib.validateShape), in one
//             ValidationContext and so one report. A request containing any
//             operation other than INSERT DATA, DELETE DATA or DELETE/INSERT
//             WHERE (for example CLEAR, DROP, LOAD, ADD, MOVE, COPY) is
//             validated whole, and the header says so.
//   Targeted mode does not re-check a focus node that the update did not
//   touch. A constraint on one resource that another resource's write can make
//   false is caught only if its shapes follow Cyril's S519 authoring rule
//   (session-519-op-134-cyril-shacl-classification, Answer 4).
//
// Shapes are read from the dataset's named graph SHAPES_GRAPH
// (urn:ontara:stack:shapes) at the start of each request's write transaction.
// The data graph validated is the dataset's union graph (every named graph),
// and the default graph for queries and update WHERE clauses is that union
// (tdb2:unionDefaultGraph), as RDF4J and GraphDB behave.
//
// Faults (500) are logged to stderr with the full stack trace (S519 Part B:
// the S518 fault left no stack trace anywhere).
package dev.ontara.spike;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.atomic.AtomicLong;

import org.apache.jena.Jena;
import org.apache.jena.fuseki.main.FusekiServer;
import org.apache.jena.fuseki.server.Operation;
import org.apache.jena.fuseki.servlets.BaseActionREST;
import org.apache.jena.fuseki.servlets.HttpAction;
import org.apache.jena.graph.Graph;
import org.apache.jena.graph.Node;
import org.apache.jena.graph.NodeFactory;
import org.apache.jena.query.TxnType;
import org.apache.jena.riot.Lang;
import org.apache.jena.riot.RDFDataMgr;
import org.apache.jena.riot.WebContent;
import org.apache.jena.shacl.GraphValidation;
import org.apache.jena.shacl.Shapes;
import org.apache.jena.shacl.ValidationReport;
import org.apache.jena.shacl.engine.ValidationContext;
import org.apache.jena.shacl.parser.Shape;
import org.apache.jena.shacl.validation.VLib;
import org.apache.jena.sparql.core.DatasetGraph;
import org.apache.jena.sparql.core.DatasetGraphWrapper;
import org.apache.jena.sparql.core.Quad;
import org.apache.jena.sparql.graph.GraphFactory;
import org.apache.jena.sparql.modify.request.UpdateDataDelete;
import org.apache.jena.sparql.modify.request.UpdateDataInsert;
import org.apache.jena.sparql.modify.request.UpdateModify;
import org.apache.jena.tdb2.TDB2;
import org.apache.jena.tdb2.TDB2Factory;
import org.apache.jena.update.Update;
import org.apache.jena.update.UpdateAction;
import org.apache.jena.update.UpdateFactory;
import org.apache.jena.update.UpdateRequest;

public class OntaraFuseki {
    static final String SHAPES_GRAPH = env("SHAPES_GRAPH", "urn:ontara:stack:shapes");
    static final String JENA_BUILD_VERSION = env("JENA_VERSION", "unknown");
    static final String MODE = env("ONTARA_VALIDATION", "whole");
    static final AtomicLong SEQ = new AtomicLong();

    static String env(String k, String d) { String v = System.getenv(k); return v == null || v.isEmpty() ? d : v; }

    public static void main(String... args) {
        if (!MODE.equals("whole") && !MODE.equals("targeted")) throw new IllegalArgumentException("ONTARA_VALIDATION must be whole or targeted, not " + MODE);
        String base = env("FUSEKI_DATA", "/fuseki/databases");
        int port = Integer.parseInt(env("FUSEKI_PORT", "3030"));
        Operation op = Operation.alloc("https://ontara.dev/spike/fuseki#validated-update", "validated-update",
                "SHACL-validated SPARQL Update (jena-shacl)");
        FusekiServer.Builder b = FusekiServer.create().port(port).registerOperation(op, WebContent.contentTypeSPARQLUpdate, new ValidatedUpdate());
        for (String name : List.of("cafe-runtime", "cafe-capability-scratch")) {
            DatasetGraph dsg = TDB2Factory.connectDataset(base + "/" + name).asDatasetGraph();
            dsg.getContext().set(TDB2.symUnionDefaultGraph, true);
            b.add("/" + name, dsg, true).addEndpoint("/" + name, "validated-update", op);
        }
        FusekiServer server = b.build();
        server.start();
        System.out.println("[ontara-fuseki] Jena " + Jena.VERSION + " (built for " + JENA_BUILD_VERSION + ") on :" + port
                + ", data " + base + ", validation " + MODE + ", shapes graph <" + SHAPES_GRAPH + ">");
        server.join();
    }

    static String engine() {
        return MODE.equals("targeted")
                ? "jena-shacl targeted (nodes the update touched, VLib.isFocusNode + VLib.validateShape; whole graph for other update forms)"
                : "jena-shacl GraphValidation.update (whole union graph)";
    }

    // Records the subject and object of every quad an update adds or deletes,
    // then passes the change to the TDB2 dataset. The default graph seen by
    // the update's WHERE clauses is the union graph, as with
    // tdb2:unionDefaultGraph on the dataset itself.
    static class Recorder extends DatasetGraphWrapper {
        final Set<Node> touched = new LinkedHashSet<>();
        long changes = 0;
        Recorder(DatasetGraph dsg) { super(dsg); }
        void note(Node s, Node o) { changes++; touched.add(s); touched.add(o); }
        @Override public Graph getDefaultGraph() { return get().getUnionGraph(); }
        @Override public void add(Quad q) { note(q.getSubject(), q.getObject()); super.add(q); }
        @Override public void delete(Quad q) { note(q.getSubject(), q.getObject()); super.delete(q); }
        @Override public void add(Node g, Node s, Node p, Node o) { note(s, o); super.add(g, s, p, o); }
        @Override public void delete(Node g, Node s, Node p, Node o) { note(s, o); super.delete(g, s, p, o); }
        @Override public void deleteAny(Node g, Node s, Node p, Node o) {
            List<Quad> qs = new ArrayList<>();
            get().find(g, s, p, o).forEachRemaining(qs::add);
            for (Quad q : qs) delete(q);
        }
    }

    static boolean targetable(UpdateRequest req) {
        for (Update u : req.getOperations())
            if (!(u instanceof UpdateDataInsert || u instanceof UpdateDataDelete || u instanceof UpdateModify)) return false;
        return true;
    }

    static class ValidatedUpdate extends BaseActionREST {
        @Override
        protected void doGet(HttpAction action) {
            DatasetGraph dsg = action.getDataset();
            long shapes = dsg.calculateRead(() -> dsg.getGraph(NodeFactory.createURI(SHAPES_GRAPH)).size());
            String json = "{\"module\": \"ontara-fuseki-validated-update 0.2.0\", \"jenaVersion\": \"" + Jena.VERSION
                    + "\", \"jenaBuildVersion\": \"" + JENA_BUILD_VERSION
                    + "\", \"fusekiVersion\": \"" + Jena.VERSION + "\", \"store\": \"TDB2\", \"unionDefaultGraph\": "
                    + dsg.getContext().isTrue(TDB2.symUnionDefaultGraph) + ", \"validating\": true, \"validationMode\": \"" + MODE + "\", "
                    + "\"engine\": \"" + engine() + "\", \"shapesGraph\": \"" + SHAPES_GRAPH
                    + "\", \"shapesTriples\": " + shapes + ", \"inference\": \"none\"}";
            reply(action, 200, "application/json", json, null, null);
        }

        @Override
        protected void doPost(HttpAction action) {
            long seq = SEQ.incrementAndGet();
            String body;
            try (InputStream in = action.getRequestInputStream()) {
                body = new String(in.readAllBytes(), StandardCharsets.UTF_8);
            } catch (IOException e) { reply(action, 500, "text/plain", "read: " + e, null, null); return; }
            UpdateRequest req;
            try { req = UpdateFactory.create(body); }
            catch (Exception e) { reply(action, 400, "text/plain", "parse: " + e.getMessage(), null, null); return; }

            DatasetGraph dsg = action.getDataset();
            String how = MODE;
            dsg.begin(TxnType.WRITE);
            try {
                // Shapes: copied out of the shapes graph inside this transaction.
                Graph shapesGraph = GraphFactory.createDefaultGraph();
                dsg.getGraph(NodeFactory.createURI(SHAPES_GRAPH)).find().forEachRemaining(shapesGraph::add);
                Shapes shapes = Shapes.parse(shapesGraph);
                Graph data = dsg.getUnionGraph();
                ValidationReport report;
                if (MODE.equals("targeted") && targetable(req)) {
                    Recorder rec = new Recorder(dsg);
                    UpdateAction.execute(req, rec);
                    ValidationContext vCxt = ValidationContext.create(shapes, data);
                    int focus = 0;
                    for (Node n : rec.touched) {
                        for (Shape shape : shapes.getTargetShapes()) {
                            if (VLib.isFocusNode(shape, n, data)) { focus++; VLib.validateShape(vCxt, data, shape, n); }
                        }
                    }
                    report = vCxt.generateReport();
                    how = "targeted; changes=" + rec.changes + " touched=" + rec.touched.size() + " focus=" + focus;
                } else {
                    if (MODE.equals("targeted")) how = "whole (targeted mode: request has an operation other than INSERT DATA, DELETE DATA or DELETE/INSERT)";
                    // GraphValidation.update runs the update inside the graph's
                    // transaction (here, the one just begun), validates the whole
                    // graph, and throws ShaclValidationException if it does not
                    // conform; updateAndReport returns that report instead.
                    report = GraphValidation.updateAndReport(shapes, data, () -> UpdateAction.execute(req, dsg));
                }
                if (report.conforms()) {
                    dsg.commit();
                    reply(action, 200, "application/json", "{\"outcome\": \"committed\"}", "committed", how);
                } else {
                    dsg.abort();
                    System.err.println("[ontara-fuseki] " + Instant.now() + " #" + seq + " rejected (aborted), " + report.getEntries().size() + " result(s); " + how);
                    java.io.ByteArrayOutputStream out = new java.io.ByteArrayOutputStream();
                    RDFDataMgr.write(out, report.getGraph(), Lang.NTRIPLES);
                    reply(action, 422, "application/shacl-validation-report+n-triples", out.toString(StandardCharsets.UTF_8), "aborted", how);
                }
            } catch (Throwable e) {
                try { if (dsg.isInTransaction()) dsg.abort(); } catch (Throwable ignore) { }
                System.err.println("[ontara-fuseki] " + Instant.now() + " #" + seq + " FAULT (aborted): " + e);
                e.printStackTrace(System.err);
                reply(action, 500, "text/plain", "fault: " + e, "aborted", how);
            } finally {
                if (dsg.isInTransaction()) dsg.end();
            }
        }

        static void reply(HttpAction action, int status, String type, String text, String txn, String how) {
            action.setResponseStatus(status);
            action.setResponseContentType(type);
            if (txn != null) action.setResponseHeader("X-Ontara-Transaction", txn);
            if (how != null) action.setResponseHeader("X-Ontara-Validation", how);
            try {
                OutputStream os = action.getResponseOutputStream();
                os.write(text.getBytes(StandardCharsets.UTF_8));
                os.flush();
            } catch (IOException e) { throw new RuntimeException(e); }
        }
    }
}
