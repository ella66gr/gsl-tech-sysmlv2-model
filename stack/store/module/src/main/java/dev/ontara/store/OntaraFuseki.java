// Ontara's validated-update module for Apache Jena Fuseki: the Cafe runtime
// store (ADR-014). Each SPARQL Update request sent to the module's endpoint
// runs inside one TDB2 write transaction and is validated with jena-shacl, so
// a violating update aborts its transaction.
//
// Production configuration since S0.5 Pass B1 (S525); before that, the OP-134
// spike's module (S518 to S521). stack/README.md section 8 documents the
// configuration this class implements.
//
// The version: pom.xml <version> is the one source. Maven writes it into the
// jar's file name and into the jar manifest (Implementation-Version), and the
// status reads it from the manifest (VERSION below). The module refuses to
// start without it.
//
// Two TDB2 datasets, fixed at start: /cafe-runtime and /cafe-capability-scratch.
// Each has its union graph as the default graph, and the module's endpoint:
//   POST /{dataset}/validated-update   application/sparql-update
//        200  committed
//        422  SHACL rejection: the validation report as N-Triples
//             (Content-Type application/shacl-validation-report+n-triples);
//             the TDB2 write transaction was aborted
//        400  the request does not parse;  500 any other fault (aborted)
//   GET  /{dataset}/validated-update   JSON status
// Response header X-Ontara-Validation says how the request was validated.
//
// Two listeners, one JVM, the same datasets (B1 item 3):
//   FUSEKI_PORT (3030), the stack-network listener: Fuseki's standard
//     endpoints with writes (query, update, Graph Store Protocol read-write on
//     /data and on the dataset itself) and the module's endpoint. Not
//     published: only containers on the stack's own network reach it. The
//     bootstrap's knowledge-graph and shapes load and the capability checks'
//     scratch clearing use it.
//   FUSEKI_PUBLISHED_PORT (3031), the published listener (compose.yaml maps
//     127.0.0.1:7210 to it): Fuseki's standard endpoints read-only (query,
//     Graph Store Protocol read) and the module's endpoint. Fuseki's
//     unvalidated write routes do not exist on it, so a write sent to them
//     from the host is refused, whatever its source address.
//
// Validation mode, set by ONTARA_VALIDATION:
//   whole     jena-shacl GraphValidation.updateAndReport: run the update, then
//             validate every shape against the whole union graph.
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
//   false is caught only if its shapes follow the shape-authoring rule
//   (ADR-014 section 4.3).
//
// Shapes are read from the dataset's named graph SHAPES_GRAPH
// (urn:ontara:stack:shapes) at the start of each request's write transaction.
// The data graph validated is the dataset's union graph (every named graph).
//
// The status's "validating" field is measured at each status request (see
// status()): true only when (1) the module's own validation code, in this
// store's mode, run now on a fixed in-memory probe, rejects each known
// violation and commits the conforming case, and (2) the dataset's shapes
// graph parses and holds at least one shape with a target, so a write to this
// dataset is checked against something. Either failing reads false.
//
// Faults (500) are logged to stderr with the full stack trace.
package dev.ontara.store;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.atomic.AtomicLong;

import org.apache.jena.Jena;
import org.apache.jena.atlas.json.JSON;
import org.apache.jena.atlas.json.JsonArray;
import org.apache.jena.atlas.json.JsonObject;
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
import org.apache.jena.riot.RDFParser;
import org.apache.jena.riot.WebContent;
import org.apache.jena.shacl.GraphValidation;
import org.apache.jena.shacl.Shapes;
import org.apache.jena.shacl.ValidationReport;
import org.apache.jena.shacl.engine.ValidationContext;
import org.apache.jena.shacl.parser.Shape;
import org.apache.jena.shacl.validation.VLib;
import org.apache.jena.sparql.core.DatasetGraph;
import org.apache.jena.sparql.core.DatasetGraphFactory;
import org.apache.jena.sparql.core.DatasetGraphWrapper;
import org.apache.jena.sparql.core.Quad;
import org.apache.jena.sparql.graph.GraphFactory;
import org.apache.jena.sparql.modify.request.UpdateDataDelete;
import org.apache.jena.sparql.modify.request.UpdateDataInsert;
import org.apache.jena.sparql.modify.request.UpdateModify;
import org.apache.jena.tdb2.DatabaseMgr;
import org.apache.jena.tdb2.TDB2;
import org.apache.jena.tdb2.TDB2Factory;
import org.apache.jena.update.Update;
import org.apache.jena.update.UpdateAction;
import org.apache.jena.update.UpdateFactory;
import org.apache.jena.update.UpdateRequest;

public class OntaraFuseki {
    static final String MODULE = "ontara-fuseki-validated-update";
    // From the jar manifest, which Maven writes from pom.xml <version>.
    static final String VERSION = OntaraFuseki.class.getPackage().getImplementationVersion();
    static final String SHAPES_GRAPH = env("SHAPES_GRAPH", "urn:ontara:stack:shapes");
    static final String JENA_BUILD_VERSION = env("JENA_VERSION", "unknown");
    static final String MODE = env("ONTARA_VALIDATION", "whole");
    static final List<String> DATASETS = List.of("cafe-runtime", "cafe-capability-scratch");
    static final AtomicLong SEQ = new AtomicLong();

    static String env(String k, String d) { String v = System.getenv(k); return v == null || v.isEmpty() ? d : v; }

    // Which listener a request arrived on.
    enum Listener {
        STACK("stack-network", true), PUBLISHED("published", false);
        final String label; final boolean standardWrites;
        Listener(String label, boolean standardWrites) { this.label = label; this.standardWrites = standardWrites; }
    }

    public static void main(String... args) {
        if (VERSION == null || VERSION.isEmpty())
            throw new IllegalStateException("no module version: the jar manifest has no Implementation-Version (build the module with Maven, stack/store/Dockerfile)");
        if (!MODE.equals("whole") && !MODE.equals("targeted")) throw new IllegalArgumentException("ONTARA_VALIDATION must be whole or targeted, not " + MODE);
        String base = env("FUSEKI_DATA", "/fuseki/databases");
        int stackPort = Integer.parseInt(env("FUSEKI_PORT", "3030"));
        int publishedPort = Integer.parseInt(env("FUSEKI_PUBLISHED_PORT", "3031"));
        if (stackPort == publishedPort) throw new IllegalArgumentException("FUSEKI_PORT and FUSEKI_PUBLISHED_PORT must differ, both are " + stackPort);
        Operation op = Operation.alloc("https://ontara.dev/store/fuseki#validated-update", "validated-update",
                "SHACL-validated SPARQL Update (jena-shacl)");
        Map<String, DatasetGraph> datasets = new LinkedHashMap<>();
        for (String name : DATASETS) {
            DatasetGraph dsg = TDB2Factory.connectDataset(base + "/" + name).asDatasetGraph();
            dsg.getContext().set(TDB2.symUnionDefaultGraph, true);
            datasets.put(name, dsg);
        }
        FusekiServer stack = server(stackPort, op, datasets, Listener.STACK);
        FusekiServer published = server(publishedPort, op, datasets, Listener.PUBLISHED);
        try {
            stack.start();
            published.start();
        } catch (RuntimeException e) {
            System.err.println("[ontara-fuseki] could not start both listeners: " + e);
            e.printStackTrace(System.err);
            System.exit(1);
        }
        Probe p = probe();
        System.out.println("[ontara-fuseki] " + MODULE + " " + VERSION + ", Jena " + Jena.VERSION + " (built for " + JENA_BUILD_VERSION + "), data " + base
                + ", validation " + MODE + ", shapes graph <" + SHAPES_GRAPH + ">; listeners: :" + stackPort
                + " stack network (standard endpoints read-write, and validated-update), :" + publishedPort
                + " published (standard endpoints read-only, and validated-update); validation probe " + (p.passed() ? "passed" : "FAILED " + p.cases()));
        stack.join();
    }

    static FusekiServer server(int port, Operation op, Map<String, DatasetGraph> datasets, Listener listener) {
        FusekiServer.Builder b = FusekiServer.create().port(port)
                .registerOperation(op, WebContent.contentTypeSPARQLUpdate, new ValidatedUpdate(listener));
        for (Map.Entry<String, DatasetGraph> e : datasets.entrySet())
            b.add("/" + e.getKey(), e.getValue(), listener.standardWrites).addEndpoint("/" + e.getKey(), "validated-update", op);
        return b.build();
    }

    static String engine() {
        return MODE.equals("targeted")
                ? "jena-shacl targeted (nodes the update touched, VLib.isFocusNode + VLib.validateShape; whole graph for other update forms)"
                : "jena-shacl GraphValidation.update (whole union graph)";
    }

    // Records the subject and object of every quad an update adds or deletes,
    // then passes the change to the dataset. The default graph seen by the
    // update's WHERE clauses is the union graph, as with tdb2:unionDefaultGraph
    // on the dataset itself.
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

    record Checked(ValidationReport report, String how) {}

    // The write path's validation: runs the request inside dsg's open write
    // transaction and validates it in this module's mode. The caller commits
    // or aborts. Used by every write (ValidatedUpdate.doPost) and by the probe.
    static Checked runAndValidate(DatasetGraph dsg, UpdateRequest req) {
        // Shapes: copied out of the shapes graph inside this transaction.
        Graph shapesGraph = GraphFactory.createDefaultGraph();
        dsg.getGraph(NodeFactory.createURI(SHAPES_GRAPH)).find().forEachRemaining(shapesGraph::add);
        Shapes shapes = Shapes.parse(shapesGraph);
        Graph data = dsg.getUnionGraph();
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
            return new Checked(vCxt.generateReport(), "targeted; changes=" + rec.changes + " touched=" + rec.touched.size() + " focus=" + focus);
        }
        String how = MODE.equals("targeted")
                ? "whole (targeted mode: request has an operation other than INSERT DATA, DELETE DATA or DELETE/INSERT)"
                : MODE;
        // GraphValidation.updateAndReport runs the update inside the graph's
        // transaction (here, the one the caller began), validates the whole
        // graph, and returns the report.
        return new Checked(GraphValidation.updateAndReport(shapes, data, () -> UpdateAction.execute(req, dsg)), how);
    }

    // ---------------------------------------------------------- the probe
    // A fixed check of the write path's validation, run on a fresh in-memory
    // dataset (never the store): one shape requiring a probe property on every
    // instance of a probe class; two violating requests (one on the targeted
    // path, one with a CLEAR, so that targeted mode takes its whole-graph
    // path) and one conforming request; each run through runAndValidate, the
    // write path's own code, and then aborted.
    static final String P = "urn:ontara:store:probe#";
    static final String PROBE_SHAPES = "@prefix sh: <http://www.w3.org/ns/shacl#> .\n"
            + "<" + P + "Shape> a sh:NodeShape ; sh:targetClass <" + P + "T> ; sh:property [ sh:path <" + P + "p> ; sh:minCount 1 ] .\n";
    static final String[][] PROBE_CASES = {
            { "violation, INSERT DATA", "rejected", "INSERT DATA { GRAPH <" + P + "g> { <" + P + "n1> a <" + P + "T> } }" },
            { "violation, INSERT DATA then CLEAR", "rejected", "INSERT DATA { GRAPH <" + P + "g> { <" + P + "n2> a <" + P + "T> } } ; CLEAR SILENT GRAPH <" + P + "other>" },
            { "conforming, INSERT DATA", "committed", "INSERT DATA { GRAPH <" + P + "g> { <" + P + "n3> a <" + P + "T> ; <" + P + "p> 1 } }" },
    };

    record Probe(boolean passed, JsonArray cases, long micros) {}

    static Probe probe() {
        long t0 = System.nanoTime();
        JsonArray cases = new JsonArray();
        boolean passed = true;
        try {
            DatasetGraph mem = DatasetGraphFactory.createTxnMem();
            Graph g = GraphFactory.createDefaultGraph();
            RDFParser.fromString(PROBE_SHAPES, Lang.TURTLE).parse(g);
            Node sg = NodeFactory.createURI(SHAPES_GRAPH);
            mem.executeWrite(() -> g.find().forEachRemaining(t -> mem.add(sg, t.getSubject(), t.getPredicate(), t.getObject())));
            for (String[] c : PROBE_CASES) {
                JsonObject o = new JsonObject();
                o.put("case", c[0]);
                o.put("expected", c[1]);
                mem.begin(TxnType.WRITE);
                try {
                    Checked r = runAndValidate(mem, UpdateFactory.create(c[2]));
                    String outcome = r.report().conforms() ? "committed" : "rejected";
                    o.put("outcome", outcome);
                    o.put("validation", r.how());
                    if (!outcome.equals(c[1])) passed = false;
                } catch (Throwable e) {
                    o.put("outcome", "fault: " + e);
                    passed = false;
                } finally {
                    if (mem.isInTransaction()) { mem.abort(); mem.end(); }
                }
                cases.add(o);
            }
        } catch (Throwable e) {
            JsonObject o = new JsonObject();
            o.put("case", "probe set-up");
            o.put("outcome", "fault: " + e);
            cases.add(o);
            passed = false;
        }
        return new Probe(passed, cases, (System.nanoTime() - t0) / 1000);
    }

    // ---------------------------------------------------------- the status
    static String status(DatasetGraph dsg, Listener listener, int port) {
        Graph shapesCopy = GraphFactory.createDefaultGraph();
        dsg.begin(TxnType.READ);
        try {
            dsg.getGraph(NodeFactory.createURI(SHAPES_GRAPH)).find().forEachRemaining(shapesCopy::add);
        } finally { dsg.end(); }
        long shapesTriples = shapesCopy.size();
        long targetShapes = -1;
        String shapesError = null;
        try { targetShapes = Shapes.parse(shapesCopy).getTargetShapes().size(); }
        catch (Throwable e) { shapesError = String.valueOf(e); }
        Probe p = probe();
        boolean validating = p.passed() && targetShapes > 0;

        JsonObject o = new JsonObject();
        o.put("module", MODULE + " " + VERSION);
        o.put("moduleVersion", VERSION);
        o.put("jenaVersion", Jena.VERSION);
        o.put("jenaBuildVersion", JENA_BUILD_VERSION);
        o.put("fusekiVersion", Jena.VERSION);
        o.put("store", DatabaseMgr.isTDB2(dsg) ? "TDB2" : "not TDB2");
        o.put("unionDefaultGraph", dsg.getContext().isTrue(TDB2.symUnionDefaultGraph));
        o.put("validating", validating);
        o.put("validationMode", MODE);
        o.put("engine", engine());
        JsonObject probe = new JsonObject();
        probe.put("passed", p.passed());
        probe.put("microseconds", p.micros());
        probe.put("cases", p.cases());
        o.put("validationProbe", probe);
        o.put("shapesGraph", SHAPES_GRAPH);
        o.put("shapesTriples", shapesTriples);
        o.put("targetShapes", targetShapes);
        if (shapesError != null) o.put("shapesError", shapesError);
        o.put("inference", "none");
        JsonObject l = new JsonObject();
        l.put("name", listener.label);
        l.put("port", port);
        l.put("standardWriteEndpoints", listener.standardWrites);
        o.put("listener", l);
        return JSON.toStringFlat(o);
    }

    static class ValidatedUpdate extends BaseActionREST {
        final Listener listener;
        ValidatedUpdate(Listener listener) { this.listener = listener; }

        @Override
        protected void doGet(HttpAction action) {
            reply(action, 200, "application/json", status(action.getDataset(), listener, action.getRequestLocalPort()), null, null);
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
                Checked c = runAndValidate(dsg, req);
                how = c.how();
                ValidationReport report = c.report();
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
