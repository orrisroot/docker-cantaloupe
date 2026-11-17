# cantaloupe docker image

This image provides [cantaloupe](https://cantaloupe-project.github.io/) service.

- Docker Hub: [`orrisroot/cantaloupe`](https://hub.docker.com/r/orrisroot/cantaloupe)
- Base image: `gcr.io/distroless/java25-debian13`
- Platform: `linux/amd64`

## Tags

| Tag | Description |
|---|---|
| `latest` | Latest cantaloupe release on the latest base image |
| `<version>` (e.g. `5.0.8`) | Specific cantaloupe release |

Images are rebuilt automatically when a new cantaloupe version or an updated base image is released. Both tags are overwritten on rebuild, so pulling the same tag again picks up base image security fixes.

## Example

### Run

```sh
docker run --restart always -d --name cantaloupe -p 8182:8182 -v /data:/data orrisroot/cantaloupe
```

Images placed in `/data` on the host are served through the IIIF Image API, e.g. `http://localhost:8182/iiif/3/<filename>/info.json`.

### Use a custom configuration

Mount a custom `cantaloupe.properties` over the bundled one.

```sh
docker run --restart always -d --name cantaloupe -p 8182:8182 \
  -v /data:/data \
  -v ./cantaloupe.properties:/cantaloupe/cantaloupe.properties:ro \
  orrisroot/cantaloupe
```

## Configuration

| Item | Value |
|---|---|
| Listening port | `8182` |
| Configuration file | `/cantaloupe/cantaloupe.properties` |
| Image source directory (`FilesystemSource.BasicLookupStrategy.path_prefix`) | `/data/` (declared as a volume) |
| Log file directory (`log.application.FileAppender.pathname`) | `/var/log/cantaloupe/` |
| Filesystem cache directory (`FilesystemCache.pathname`) | `/var/cache/cantaloupe/` |

The bundled configuration file is generated from `cantaloupe.properties.sample` of the cantaloupe release, with only the image source directory and the log file directory changed. All other settings keep the sample defaults:

- Logs are written to the console. File logging (`log.application.FileAppender.enabled`) is disabled.
- The source cache (`cache.server.source`) uses `/var/cache/cantaloupe/`. The derivative cache (`cache.server.derivative.enabled`) is disabled.

To enable file logging or the derivative cache, use a custom configuration file.

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `JDK_JAVA_OPTIONS` | `-Dcantaloupe.config=/cantaloupe/cantaloupe.properties -Xmx2g` | JVM options. Keep `-Dcantaloupe.config` when overriding this variable. |

Example: increase the maximum heap size to 4 GB.

```sh
docker run -d -p 8182:8182 -v /data:/data \
  -e JDK_JAVA_OPTIONS="-Dcantaloupe.config=/cantaloupe/cantaloupe.properties -Xmx4g" \
  orrisroot/cantaloupe
```

## Build

Build the image locally with `build.sh`. The cantaloupe version is read from `ARG CANTALOUPE_VERSION` in `Dockerfile`.

```sh
./build.sh
```

The script tags the image as `orrisroot/cantaloupe:latest` and `orrisroot/cantaloupe:<version>`.
