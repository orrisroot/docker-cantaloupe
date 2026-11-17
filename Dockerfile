FROM docker.io/library/debian:trixie-slim@sha256:a72b4433de1cf7d6bae0c4cee74d0547f58601a643b3375f070c51600d63b6b2 AS build-env
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

FROM gcr.io/distroless/java25-debian13:latest@sha256:6558dff7db91bf89d34254014dec8ff1f0a3e13f48a575d5a51ce01d1597d671
ENV JDK_JAVA_OPTIONS="-Dcantaloupe.config=/cantaloupe/cantaloupe.properties -Xmx2g"
WORKDIR /cantaloupe
COPY --from=build-env /work/root/ /
VOLUME ["/data"]
EXPOSE 8182
CMD ["/cantaloupe/cantaloupe.jar"]
