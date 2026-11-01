// Opens the runtime store's adapter. One adapter at S0.1 pass 3: Fuseki.
import { config } from "../config";
import { FusekiStore } from "./fuseki";
import { Store } from "./types";

export function openStore(dataset = config.dataset, url = config.storeUrl): Store {
  return new FusekiStore(url, dataset);
}

export * from "./types";
