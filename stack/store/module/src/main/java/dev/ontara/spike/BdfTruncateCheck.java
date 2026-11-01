package dev.ontara.spike;

// OP-134 spike follow-up (S519, Part C): the minimal reproducer from Jena issue
// apache/jena#3877, run against jena-dboe-base's BinaryDataFileRandomAccess
// alone: no TDB2, no Fuseki, no Ontara module. It writes 300 KB, truncates to
// 100 KB (what TransBinaryDataFile._abort() does to nodes-data.obj on a write
// transaction's abort), reads 16 bytes (as the next transaction's node lookup
// does), then writes 100 bytes.
//   Sound:    the write lands at 102400; the file is 102500 bytes, no zero bytes.
//   GH-3877:  the write lands at the stale writePosition 307200; the file is
//             307300 bytes, with 204800 zero bytes between the two.
// Usage: java -cp '/opt/ontara-fuseki/*:/opt/ontara-fuseki/lib/*' dev.ontara.spike.BdfTruncateCheck
import java.io.File;
import java.nio.file.Files;
import java.util.Arrays;

import org.apache.jena.Jena;
import org.apache.jena.dboe.base.file.BinaryDataFileRandomAccess;

public class BdfTruncateCheck {
    public static void main(String... args) throws Exception {
        File f = File.createTempFile("bdf-gh3877-", ".bin");
        f.delete();
        BinaryDataFileRandomAccess file = new BinaryDataFileRandomAccess(f.getPath());
        file.open();
        byte[] ab = new byte[1024]; Arrays.fill(ab, (byte) 0xAB);
        for (int i = 0; i < 300; i++) file.write(ab, 0, 1024);
        String outcome;
        try {
            file.truncate(100 * 1024);
            file.read(0, new byte[16], 0, 16);
            byte[] cd = new byte[100]; Arrays.fill(cd, (byte) 0xCD);
            long pos = file.write(cd, 0, 100);
            file.sync();
            file.close();
            byte[] all = Files.readAllBytes(f.toPath());
            long zeros = 0; for (byte b : all) if (b == 0) zeros++;
            boolean sound = pos == 102400 && all.length == 102500 && zeros == 0;
            outcome = "write returned position " + pos + "; file " + all.length + " bytes; zero bytes " + zeros + " -> " + (sound ? "SOUND (writePosition reset by truncate)" : "DEFECT GH-3877 (stale writePosition)");
        } catch (RuntimeException e) {
            outcome = "refused: " + e;
        }
        System.out.println("Jena " + Jena.VERSION + " BinaryDataFileRandomAccess truncate-read-write: " + outcome);
        f.delete();
    }
}
