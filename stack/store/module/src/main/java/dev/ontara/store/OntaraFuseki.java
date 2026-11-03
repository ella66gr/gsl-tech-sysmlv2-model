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
//        403  refused by the request's write policy (below), before
//             validation: JSON naming each broken rule; aborted
//        405  a write sent to the published listener (B3; refused, nothing run)
//        400  the request does not parse;  500 any other fault (aborted)
//   GET  /{dataset}/validated-update   JSON status
// Response header X-Ontara-Validation says how the request was validated.
//
// The write policy (S0.5 Pass B3, the named-graph scheme's four write rules).
// The constraint gate decides, for each runtime write, which graphs it may
// change, and sends that as the request header X-Ontara-Write-Policy (JSON:
// allowedGraphs, protectedGraphs, runtimeGraphPrefix). The module applies it
// inside the write transaction, on the exact quads the request added or
// deleted, before validation, and aborts with 403 if any quad:
//   - is in the default graph                         (rule "default-graph");
//   - is in a protected graph (knowledge graph, shapes) (rule "knowledge-graph-or-shapes");
//   - is in a runtime graph not allowed (another DHB) (rule "other-branch");
//   - is in any other graph outside the allowed set    (rule "outside-scheme");
// or if a subject the request wrote into an allowed graph also has statements
// in a runtime graph that is not allowed: its home is another DHB (rule
// "not-home"). A policy request may use only INSERT DATA, DELETE DATA and
// DELETE/INSERT WHERE (rule "operation": CLEAR, DROP and the other
// whole-graph forms act on graphs, not quads). A request with no policy header
// (maintenance and test seeding, from the stack network only) is not checked.
//
// The Reality Reference Branch's identifier (S0.5 Pass B3; Ella, S525). When
// the module creates the runtime dataset from empty, it generates a lower-case
// UUID v4, the identifier (dhbId) of the tenant's Reality Reference Branch, and
// keeps it beside the dataset, in FUSEKI_DATA/<dataset>.rrb.json, so it lives
// and dies with the store's data. The status reports it (rrb). A runtime
// dataset that exists with no such file predates the scheme: the module
// refuses to start, and the store must be rebuilt from empty. Nothing is
// written into the store for it: Pass B writes no declaration record.
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
// (https://ontara.dev/graph/shapes since S0.5 Pass B3) at the start of each
// request's write transaction.
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
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Instant;
import java.util.ArrayList;
import java.util.IdentityHashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicLong;

import org.apache.jena.Jena;
import org.apache.jena.atlas.json.JSON;
import org.apache.jena.atlas.json.JsonArray;
import org.apache.jena.atlas.json.JsonObject;
import org.apache.jena.atlas.json.JsonValue;
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
    static final String SHAPES_GRAPH = env("SHAPES_GRAPH", "https://ontara.dev/graph/shapes");
    static final String JENA_BUILD_VERSION = env("JENA_VERSION", "unknown");
    static final String MODE = env("ONTARA_VALIDATION", "whole");
    static final List<String> DATASETS = List.of("cafe-runtime", "cafe-capability-scratch");
    // The datasets that hold a tenant's runtime, and so have a Reality Reference
    // Branch. The capability scratch dataset never holds runtime content.
    static final List<String> RUNTIME_DATASETS = List.of("cafe-runtime");
    // The RRB of each runtime dataset, by dataset (identity map: DatasetGraph).
    static final Map<DatasetGraph, JsonObject> RRB = new IdentityHashMap<>();
    static final String POLICY_HEADER = "X-Ontara-Write-Policy";
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
            boolean fresh = !Files.exists(Path.of(base, name));
            DatasetGraph dsg = TDB2Factory.connectDataset(base + "/" + name).asDatasetGraph();
            dsg.getContext().set(TDB2.symUnionDefaultGraph, true);
            datasets.put(name, dsg);
            if (RUNTIME_DATASETS.contains(name)) RRB.put(dsg, rrb(base, name, fresh));
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
                + " published (standard endpoints read-only; validated-update status only, writes refused); validation probe " + (p.passed() ? "passed" : "FAILED " + p.cases()));
        stack.join();
    }

    // The Reality Reference Branch's identifier for a runtime dataset: generated
    // when the dataset is created from empty, read back on every later start.
    static JsonObject rrb(String base, String dataset, boolean fresh) {
        Path file = Path.of(base, dataset + ".rrb.json");
        try {
            if (fresh) {
                JsonObject o = new JsonObject();
                o.put("dhbId", UUID.randomUUID().toString().toLowerCase());
                o.put("generatedAt", Instant.now().toString());
                o.put("dataset", dataset);
                o.put("note", "Generated by the store when it created this dataset from empty (S0.5 Pass B3). Kept with the store; never committed. A rebuild from empty is a new installation with a new identifier.");
                Files.writeString(file, JSON.toString(o) + "\n");
                System.out.println("[ontara-fuseki] /" + dataset + " created from empty: Reality Reference Branch dhbId " + o.getString("dhbId") + " written to " + file);
                return o;
            }
            if (!Files.exists(file)) {
                System.err.println("[ontara-fuseki] REFUSING TO START: /" + dataset + " exists in " + base + " but has no Reality Reference Branch identifier (" + file
                        + "). It predates the named-graph scheme (S0.5 Pass B3). Rebuild the store from empty (docker compose down -v), a new installation.");
                System.exit(1);
            }
            JsonObject o = JSON.parse(Files.readString(file));
            String id = o.getString("dhbId");
            if (id == null || !id.matches("[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}")) {
                System.err.println("[ontara-fuseki] REFUSING TO START: " + file + " does not hold a lower-case UUID v4 dhbId: " + o);
                System.exit(1);
            }
            return o;
        } catch (IOException e) {
            throw new RuntimeException("Reality Reference Branch identifier for /" + dataset + ": " + e, e);
        }
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
        final List<Quad> added = new ArrayList<>();
        final List<Quad> deleted = new ArrayList<>();
        long changes = 0;
        Recorder(DatasetGraph dsg) { super(dsg); }
        void note(Node s, Node o) { changes++; touched.add(s); touched.add(o); }
        @Override public Graph getDefaultGraph() { return get().getUnionGraph(); }
        @Override public void add(Quad q) { note(q.getSubject(), q.getObject()); added.add(q); super.add(q); }
        @Override public void delete(Quad q) { note(q.getSubject(), q.getObject()); deleted.add(q); super.delete(q); }
        @Override public void add(Node g, Node s, Node p, Node o) { note(s, o); added.add(Quad.create(g, s, p, o)); super.add(g, s, p, o); }
        @Override public void delete(Node g, Node s, Node p, Node o) { note(s, o); deleted.add(Quad.create(g, s, p, o)); super.delete(g, s, p, o); }
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

    // A request's write policy (header X-Ontara-Write-Policy), from the gate.
    record Policy(Set<String> allowed, Set<String> protectedGraphs, String runtimePrefix) {
        static Policy parse(String json) {
            JsonObject o = JSON.parse(json);
            Set<String> allowed = new LinkedHashSet<>(), prot = new LinkedHashSet<>();
            for (JsonValue v : o.get("allowedGraphs").getAsArray()) allowed.add(v.getAsString().value());
            for (JsonValue v : o.get("protectedGraphs").getAsArray()) prot.add(v.getAsString().value());
            String prefix = o.getString("runtimeGraphPrefix");
            if (allowed.isEmpty() || prefix == null || prefix.isEmpty()) throw new IllegalArgumentException("write policy needs allowedGraphs and runtimeGraphPrefix");
            return new Policy(allowed, prot, prefix);
        }
    }

    record Checked(ValidationReport report, String how, JsonArray refusals) {}

    static JsonObject refusal(String rule, Node g, Quad q, String detail) {
        JsonObject o = new JsonObject();
        o.put("rule", rule);
        o.put("graph", g == null || Quad.isDefaultGraph(g) ? "(default graph)" : g.toString());
        if (q != null) o.put("quad", q.getSubject() + " " + q.getPredicate() + " " + q.getObject());
        if (detail != null) o.put("detail", detail);
        return o;
    }

    // The write policy, on the quads the request changed, inside its transaction.
    static JsonArray policyRefusals(DatasetGraph dsg, Recorder rec, Policy pol) {
        JsonArray out = new JsonArray();
        Set<String> seenRuleGraph = new LinkedHashSet<>();
        List<Quad> all = new ArrayList<>(rec.added);
        all.addAll(rec.deleted);
        for (Quad q : all) {
            Node g = q.getGraph();
            String rule;
            if (g == null || Quad.isDefaultGraph(g)) rule = "default-graph";
            else if (!g.isURI()) rule = "outside-scheme";
            else if (pol.protectedGraphs().contains(g.getURI())) rule = "knowledge-graph-or-shapes";
            else if (pol.allowed().contains(g.getURI())) continue;
            else if (g.getURI().startsWith(pol.runtimePrefix())) rule = "other-branch";
            else rule = "outside-scheme";
            if (seenRuleGraph.add(rule + " " + g) && out.size() < 20) out.add(refusal(rule, g, q, null));
        }
        // One home: a subject written into an allowed graph has no statements in
        // a runtime graph outside the allowed set.
        Set<Node> subjects = new LinkedHashSet<>();
        for (Quad q : rec.added) if (q.getSubject().isURI() && q.getGraph() != null && q.getGraph().isURI() && pol.allowed().contains(q.getGraph().getURI())) subjects.add(q.getSubject());
        for (Node s : subjects) {
            var it = dsg.find(Node.ANY, s, Node.ANY, Node.ANY);
            try {
                while (it.hasNext()) {
                    Node g = it.next().getGraph();
                    if (g.isURI() && g.getURI().startsWith(pol.runtimePrefix()) && !pol.allowed().contains(g.getURI())) {
                        if (out.size() < 20) out.add(refusal("not-home", g, null, "subject " + s + " has its home in " + g));
                        break;
                    }
                }
            } finally { org.apache.jena.atlas.iterator.Iter.close(it); }
        }
        return out;
    }

    // The write path's validation: runs the request inside dsg's open write
    // transaction and validates it in this module's mode. The caller commits
    // or aborts. Used by every write (ValidatedUpdate.doPost) and by the probe.
    // With a write policy, the changed quads are checked against it first; a
    // refusal returns before validation (report null).
    static Checked runAndValidate(DatasetGraph dsg, UpdateRequest req) { return runAndValidate(dsg, req, null); }

    static Checked runAndValidate(DatasetGraph dsg, UpdateRequest req, Policy pol) {
        if (pol != null && !targetable(req)) {
            JsonArray r = new JsonArray();
            r.add(refusal("operation", null, null, "a runtime write may use only INSERT DATA, DELETE DATA and DELETE/INSERT WHERE: CLEAR, DROP, LOAD, ADD, MOVE and COPY act on whole graphs"));
            r.get(0).getAsObject().put("graph", "(not run)");
            return new Checked(null, "not run: refused by the write policy", r);
        }
        // Shapes: copied out of the shapes graph inside this transaction.
        Graph shapesGraph = GraphFactory.createDefaultGraph();
        dsg.getGraph(NodeFactory.createURI(SHAPES_GRAPH)).find().forEachRemaining(shapesGraph::add);
        Shapes shapes = Shapes.parse(shapesGraph);
        Graph data = dsg.getUnionGraph();
        if (pol != null && !(MODE.equals("targeted"))) {
            // Whole mode with a policy: the update runs through the recorder,
            // inside the same updateAndReport call as without a policy, and the
            // changed quads are checked against the policy before the report is used.
            Recorder rec = new Recorder(dsg);
            JsonArray[] refused = { new JsonArray() };
            ValidationReport report = GraphValidation.updateAndReport(shapes, data, () -> {
                UpdateAction.execute(req, rec);
                refused[0] = policyRefusals(dsg, rec, pol);
            });
            if (refused[0].size() > 0) return new Checked(null, "not validated: refused by the write policy", refused[0]);
            return new Checked(report, MODE, null);
        }
        if (MODE.equals("targeted") && targetable(req)) {
            Recorder rec = new Recorder(dsg);
            UpdateAction.execute(req, rec);
            if (pol != null) {
                JsonArray refused = policyRefusals(dsg, rec, pol);
                if (refused.size() > 0) return new Checked(null, "not validated: refused by the write policy", refused);
            }
            ValidationContext vCxt = ValidationContext.create(shapes, data);
            int focus = 0;
            for (Node n : rec.touched) {
                for (Shape shape : shapes.getTargetShapes()) {
                    if (VLib.isFocusNode(shape, n, data)) { focus++; VLib.validateShape(vCxt, data, shape, n); }
                }
            }
            return new Checked(vCxt.generateReport(), "targeted; changes=" + rec.changes + " touched=" + rec.touched.size() + " focus=" + focus, null);
        }
        String how = MODE.equals("targeted")
                ? "whole (targeted mode: request has an operation other than INSERT DATA, DELETE DATA or DELETE/INSERT)"
                : MODE;
        // GraphValidation.updateAndReport runs the update inside the graph's
        // transaction (here, the one the caller began), validates the whole
        // graph, and returns the report.
        return new Checked(GraphValidation.updateAndReport(shapes, data, () -> UpdateAction.execute(req, dsg)), how, null);
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
        JsonObject r = RRB.get(dsg);
        if (r != null) {
            JsonObject rr = new JsonObject();
            rr.put("dhbId", r.getString("dhbId"));
            rr.put("generatedAt", r.getString("generatedAt"));
            o.put("rrb", rr);
        } else o.put("rrb", org.apache.jena.atlas.json.JsonNull.instance);
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
            if (!listener.standardWrites) {
                // S0.5 Pass B3: the published listener takes no writes at all. A
                // runtime write passes the gate's write rules and its Write
                // Stamping Stage, which a write sent straight here would skip.
                reply(action, 405, "application/json", "{\"outcome\": \"refused\", \"detail\": \"validated-update takes writes only on the stack network (store:3030), from the gate; on the published listener it serves the status (GET) only\"}", null, null);
                return;
            }
            String body;
            try (InputStream in = action.getRequestInputStream()) {
                body = new String(in.readAllBytes(), StandardCharsets.UTF_8);
            } catch (IOException e) { reply(action, 500, "text/plain", "read: " + e, null, null); return; }
            UpdateRequest req;
            try { req = UpdateFactory.create(body); }
            catch (Exception e) { reply(action, 400, "text/plain", "parse: " + e.getMessage(), null, null); return; }

            Policy pol = null;
            String policyHeader = action.getRequestHeader(POLICY_HEADER);
            if (policyHeader != null && !policyHeader.isBlank()) {
                try { pol = Policy.parse(policyHeader); }
                catch (Exception e) { reply(action, 400, "text/plain", "write policy: " + e.getMessage(), null, null); return; }
            }

            DatasetGraph dsg = action.getDataset();
            String how = MODE;
            dsg.begin(TxnType.WRITE);
            try {
                Checked c = runAndValidate(dsg, req, pol);
                how = c.how();
                if (c.refusals() != null) {
                    dsg.abort();
                    JsonObject o = new JsonObject();
                    o.put("outcome", "refused");
                    Set<String> rules = new LinkedHashSet<>();
                    for (JsonValue v : c.refusals()) rules.add(v.getAsObject().getString("rule"));
                    JsonArray ra = new JsonArray();
                    rules.forEach(ra::add);
                    o.put("rules", ra);
                    o.put("violations", c.refusals());
                    System.err.println("[ontara-fuseki] " + Instant.now() + " #" + seq + " refused by the write policy (aborted): " + rules);
                    reply(action, 403, "application/json", JSON.toStringFlat(o), "aborted", how);
                    return;
                }
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
