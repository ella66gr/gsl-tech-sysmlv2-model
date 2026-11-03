package dev.ontara.store.check;

// OP-134 spike follow-up (S519, Part C): offline integrity check of a TDB2
// database, run in the Fuseki image with the store STOPPED (TDB2 locks its
// directory to one JVM). Two checks:
//   1. physical: scan every Data-*/nodes-data.obj for runs of zero bytes of at
//      least MINRUN bytes. Jena GH-3877 (TDB2 abort, fixed in 6.1.0) leaves
//      exactly this: a zero-filled gap inside the append-only node data file,
//      as long as the aborted transaction's node bytes (one short IRI is about
//      50 bytes). Jena's RDF Thrift encoding of a node holds at most about ten
//      zero bytes in a row (an 8-byte double 0.0 next to field-stop bytes), so
//      a run of 32 or more is the defect's signature.
//   2. logical: in one read transaction, iterate every quad and turn every
//      NodeId into its node, counting quads; the first failure is printed with
//      its full stack trace.
// Compiled into the module jar (the JRE image has no compiler). Usage (bin/regression-check.sh runs it):
//   java -cp '/opt/ontara-fuseki/*:/opt/ontara-fuseki/lib/*' dev.ontara.store.check.NodeTableCheck <database directory> [MINRUN]
import java.io.RandomAccessFile;
import java.nio.file.*;
import java.util.*;

import org.apache.jena.Jena;
import org.apache.jena.sparql.core.DatasetGraph;
import org.apache.jena.sparql.core.Quad;
import org.apache.jena.tdb2.TDB2Factory;

public class NodeTableCheck {
    public static void main(String[] args) throws Exception {
        Path db = Paths.get(args[0]);
        int minRun = args.length > 1 ? Integer.parseInt(args[1]) : 32;
        System.out.println("Jena " + Jena.VERSION + ", database " + db + ", zero-run threshold " + minRun + " bytes");
        List<Path> files = new ArrayList<>();
        try (var s = Files.walk(db)) { s.filter(p -> p.getFileName().toString().equals("nodes-data.obj")).sorted().forEach(files::add); }
        for (Path f : files) {
            long len = Files.size(f);
            List<long[]> runs = new ArrayList<>();
            try (RandomAccessFile raf = new RandomAccessFile(f.toFile(), "r")) {
                byte[] buf = new byte[1 << 20];
                long pos = 0, runStart = -1;
                int n;
                while ((n = raf.read(buf)) > 0) {
                    for (int i = 0; i < n; i++) {
                        if (buf[i] == 0) { if (runStart < 0) runStart = pos + i; }
                        else if (runStart >= 0) { if (pos + i - runStart >= minRun) runs.add(new long[]{runStart, pos + i - runStart}); runStart = -1; }
                    }
                    pos += n;
                }
                if (runStart >= 0 && pos - runStart >= minRun) runs.add(new long[]{runStart, pos - runStart});
            }
            long total = runs.stream().mapToLong(r -> r[1]).sum();
            System.out.println("PHYSICAL " + db.relativize(f) + ": " + len + " bytes; zero runs >= " + minRun + ": " + runs.size() + ", " + total + " bytes in all");
            for (int i = 0; i < Math.min(runs.size(), 20); i++) System.out.println("  zero run at offset " + runs.get(i)[0] + ", length " + runs.get(i)[1]);
        }
        DatasetGraph dsg = TDB2Factory.connectDataset(db.toString()).asDatasetGraph();
        long quads = 0;
        Quad last = null;
        dsg.begin(org.apache.jena.query.TxnType.READ);
        try {
            Iterator<Quad> it = dsg.find();
            while (it.hasNext()) { last = it.next(); last.toString(); quads++; }
            System.out.println("LOGICAL read every quad: " + quads + " quads, no error");
        } catch (Throwable e) {
            System.out.println("LOGICAL read FAILED after " + quads + " quads; last good quad: " + last);
            e.printStackTrace(System.out);
        } finally { dsg.end(); }
    }
}
