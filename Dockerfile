FROM docker.io/library/openjdk:11-jdk-slim-bullseye AS build-env
ARG CANTALOUPE_VERSION=""
ENV CANTALOUPE_VERSION=${CANTALOUPE_VERSION}
WORKDIR /work
RUN test ! -z "${CANTALOUPE_VERSION}" \
    && apt update \
    && apt install -y curl unzip \
    && curl -OL https://github.com/cantaloupe-project/cantaloupe/releases/download/v${CANTALOUPE_VERSION}/cantaloupe-${CANTALOUPE_VERSION}.zip \
    && unzip cantaloupe-${CANTALOUPE_VERSION}.zip \
    && mkdir -p root/cantaloupe root/usr/lib/x86_64-linux-gnu \
    && mv cantaloupe-${CANTALOUPE_VERSION}/cantaloupe-${CANTALOUPE_VERSION}.jar root/cantaloupe/cantaloupe.jar \
    && sed \
        -e "s+^FilesystemSource.BasicLookupStrategy.path_prefix =.*+FilesystemSource.BasicLookupStrategy.path_prefix = /data/\r+g" \
        -e "s+/path/to/logs/+/var/log/cantaloupe/+g" \
        cantaloupe-${CANTALOUPE_VERSION}/cantaloupe.properties.sample > root/cantaloupe/cantaloupe.properties \
    && mv cantaloupe-${CANTALOUPE_VERSION}/deps/Linux-x86-64/lib/* root/usr/lib/x86_64-linux-gnu/

FROM gcr.io/distroless/java11-debian11:latest
ENV JDK_JAVA_OPTIONS="-Dcantaloupe.config=/cantaloupe/cantaloupe.properties -Xmx2g"
WORKDIR /cantaloupe
COPY --from=build-env /work/root/ /
VOLUME ["/data", "/var/cache/cantaloupe", "/var/log/cantaloupe"]
EXPOSE 8182
CMD ["/cantaloupe/cantaloupe.jar"]
