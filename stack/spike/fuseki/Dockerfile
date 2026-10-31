# OP-134 spike, configuration 3: Apache Jena Fuseki 5.6.0 with the Ontara
# validated-update module. Built on the machine that runs it (S0.1 image rule).
FROM maven:3.9-eclipse-temurin-21@sha256:99e61abcff91a9b1333463bd8451fb18495d6eba9250ac66a338b518f8278320 AS build
WORKDIR /src
COPY module/pom.xml ./
RUN mvn -q -B dependency:go-offline
COPY module/src ./src
RUN mvn -q -B -DskipTests package

FROM eclipse-temurin:21-jre@sha256:0b99b3376fbb50dbf9c0af8535fdd5b8eb0d3fdfc8b1e4967f383b6919f6901a
ENV JENA_VERSION=5.6.0 FUSEKI_DATA=/fuseki/databases FUSEKI_PORT=3030
WORKDIR /opt/ontara-fuseki
COPY --from=build /src/target/lib ./lib
COPY --from=build /src/target/ontara-fuseki-validated-update-0.1.0.jar ./
RUN mkdir -p /fuseki/databases
EXPOSE 3030
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -cp '/opt/ontara-fuseki/ontara-fuseki-validated-update-0.1.0.jar:/opt/ontara-fuseki/lib/*' dev.ontara.spike.OntaraFuseki"]
