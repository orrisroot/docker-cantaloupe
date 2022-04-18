# cantaloupe docker image

This image provides [cantaloupe](https://cantaloupe-project.github.io/) service. 

## Example

### Run

```sh
docker run --restart always -d --name cantaloupe -p 8182:8182 -v /data:/data orrisroot/cantaloupe
```

