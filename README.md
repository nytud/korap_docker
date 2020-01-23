# REDME

## Prepare

```sh
git clone --recurse-submodules https://github.com/dlt-rilmta/korap_docker.git
```

## `index/`

You can copy your custom `index/` directory to the repository. If you run the
docker container, it will use it.

## Build Docker image

```sh
make build
```

## Run Docker container

Interactive:

```sh
make test
```

Production:

```sh
make run
```
