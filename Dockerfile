FROM docker.io/library/debian:trixie-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0 AS build-env
# renovate: datasource=github-releases depName=cantaloupe-project/cantaloupe extractVersion=^v(?<version>.+)$
ARG CANTALOUPE_VERSION=5.0.8
ENV CANTALOUPE_VERSION=${CANTALOUPE_VERSION}
WORKDIR /work
RUN test ! -z "${CANTALOUPE_VERSION}" \
    && apt update \
    && apt install -y curl unzip \
    && curl -OL https://github.com/cantaloupe-project/cantaloupe/releases/download/v${CANTALOUPE_VERSION}/cantaloupe-${CANTALOUPE_VERSION}.zip \
    && unzip cantaloupe-${CANTALOUPE_VERSION}.zip \
    && mkdir -p root/cantaloupe root/usr/lib/x86_64-linux-gnu root/var/log/cantaloupe root/var/cache/cantaloupe \
    && mv cantaloupe-${CANTALOUPE_VERSION}/cantaloupe-${CANTALOUPE_VERSION}.jar root/cantaloupe/cantaloupe.jar \
    && sed \
        -e "s+^FilesystemSource.BasicLookupStrategy.path_prefix =.*+FilesystemSource.BasicLookupStrategy.path_prefix = /data/\r+g" \
        -e "s+/path/to/logs/+/var/log/cantaloupe/+g" \
        cantaloupe-${CANTALOUPE_VERSION}/cantaloupe.properties.sample > root/cantaloupe/cantaloupe.properties \
    && grep -q "^FilesystemSource.BasicLookupStrategy.path_prefix = /data/" root/cantaloupe/cantaloupe.properties \
    && grep -q "/var/log/cantaloupe/" root/cantaloupe/cantaloupe.properties \
    && ! grep -q "/path/to/logs/" root/cantaloupe/cantaloupe.properties \
    && mv cantaloupe-${CANTALOUPE_VERSION}/deps/Linux-x86-64/lib/* root/usr/lib/x86_64-linux-gnu/

FROM gcr.io/distroless/java25-debian13:latest@sha256:2b69a4e2c905ec18cdf267f4b3821ac9feaf737dae588a190f918079b380e434
ENV JDK_JAVA_OPTIONS="-Dcantaloupe.config=/cantaloupe/cantaloupe.properties -Xmx2g"
WORKDIR /cantaloupe
COPY --from=build-env /work/root/ /
VOLUME ["/data"]
EXPOSE 8182
CMD ["/cantaloupe/cantaloupe.jar"]
