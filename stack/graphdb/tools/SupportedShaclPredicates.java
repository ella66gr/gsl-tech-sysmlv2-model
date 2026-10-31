// Prints, as JSON, the SHACL predicates RDF4J's ShaclSail declares it supports
// (ShaclSail.getSupportedShaclPredicates()), using the jars inside the GraphDB
// image itself. Run by stack/bin/capabilities.sh:
//   java -cp '/opt/graphdb/dist/lib/*' /opt/stack-tools/SupportedShaclPredicates.java
import org.eclipse.rdf4j.sail.shacl.ShaclSail;
import java.util.stream.Collectors;

public class SupportedShaclPredicates {
  public static void main(String[] args) {
    String list = ShaclSail.getSupportedShaclPredicates().stream()
        .map(Object::toString).sorted()
        .map(s -> "    \"" + s + "\"")
        .collect(Collectors.joining(",\n"));
    String impl = ShaclSail.class.getPackage().getImplementationVersion();
    System.out.println("{\n  \"source\": \"org.eclipse.rdf4j.sail.shacl.ShaclSail.getSupportedShaclPredicates()\",\n"
        + "  \"rdf4jShaclJarVersion\": \"" + impl + "\",\n  \"predicates\": [\n" + list + "\n  ]\n}");
  }
}
