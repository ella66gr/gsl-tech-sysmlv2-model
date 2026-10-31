// Opens the store adapter named by STORE_KIND (OP-134 spike, B1).
import { config } from "../config";
import { GraphDB } from "./graphdb-client";
import { GraphDBStore } from "./graphdb";
import { Rdf4jStore } from "./rdf4j";
import { FusekiStore } from "./fuseki";
import { OxigraphStore } from "./oxigraph";
import { Store } from "./types";

export function openStore(repository = config.repository): Store {
  switch (config.storeKind) {
    case "graphdb": return new GraphDBStore(new GraphDB(config.storeUrl, repository));
    case "rdf4j": return new Rdf4jStore(new GraphDB(config.storeUrl, repository), config.rdf4jDelegate);
    case "fuseki": return new FusekiStore(config.storeUrl, repository);
    case "oxigraph": return new OxigraphStore(config.storeUrl, repository);
    default: throw new Error(`STORE_KIND=${config.storeKind} is not a known store adapter`);
  }
}

export * from "./types";
