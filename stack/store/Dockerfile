# Ontara Cafe runtime store: Apache Jena Fuseki (embedded), TDB2 storage, and
# Ontara's validated-update module (module/), which validates every write with
# jena-shacl inside its TDB2 write transaction (ADR-014).
#
# Built by `docker compose build` on the machine that runs it (S0.1 image
# rule, specification section 2.5 item 10); never carried between machines.
# Ported from the OP-134 spike (spike/op-134-store, stack/spike/fuseki/) at
# S521, S0.1 pass 3.
#
# JENA_VERSION is a build argument, pinned by compose.yaml at 6.2.0. The build
# FAILS for any version below 6.1.0: Jena 5.x and 6.0.x carry the TDB2 abort
# defect (apache/jena#3877) that silently loses confirmed writes (ADR-014 §6).
ARG JENA_VERSION=6.2.0

FROM maven:3.9-eclipse-temurin-21@sha256:99e61abcff91a9b1333463bd8451fb18495d6eba9250ac66a338b518f8278320 AS build
ARG JENA_VERSION
# The version floor, checked before anything is downloaded.
RUN set -eu; v="${JENA_VERSION}"; floor=6.1.0; \
    if ! printf '%s' "$v" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then \
      echo "JENA_VERSION=$v is not a release version (N.N.N). Refusing to build." >&2; exit 1; fi; \
    lowest="$(printf '%s\n%s\n' "$v" "$floor" | sort -V | head -n 1)"; \
    if [ "$lowest" != "$floor" ]; then \
      echo "JENA_VERSION=$v is below $floor: Jena before 6.1.0 has the TDB2 abort defect (apache/jena#3877; ADR-014). Refusing to build." >&2; exit 1; fi; \
    echo "JENA_VERSION=$v: at or above the floor $floor"
WORKDIR /src
COPY module/pom.xml ./
RUN mvn -q -B -Djena.version=${JENA_VERSION} dependency:go-offline
COPY module/src ./src
# The resolved Jena jars must be of the requested version.
RUN mvn -q -B -Djena.version=${JENA_VERSION} -DskipTests package \
 && ls target/lib | grep -E '^jena-(arq|core|shacl|tdb2|fuseki-main|dboe-base)-' > target/jena-jars.txt \
 && test "$(grep -c -- "-${JENA_VERSION}.jar" target/jena-jars.txt)" -eq "$(wc -l < target/jena-jars.txt)"

FROM eclipse-temurin:21-jre@sha256:0b99b3376fbb50dbf9c0af8535fdd5b8eb0d3fdfc8b1e4967f383b6919f6901a
ARG JENA_VERSION
ENV JENA_VERSION=${JENA_VERSION} FUSEKI_DATA=/fuseki/databases FUSEKI_PORT=3030
LABEL org.opencontainers.image.title="ontara-cafe-stack store" \
      dev.ontara.jena-version="${JENA_VERSION}"
WORKDIR /opt/ontara-fuseki
COPY --from=build /src/target/lib ./lib
COPY --from=build /src/target/jena-jars.txt ./
COPY --from=build /src/target/ontara-fuseki-validated-update-0.1.0.jar ./
RUN mkdir -p /fuseki/databases
EXPOSE 3030
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -cp '/opt/ontara-fuseki/ontara-fuseki-validated-update-0.1.0.jar:/opt/ontara-fuseki/lib/*' dev.ontara.spike.OntaraFuseki"]
