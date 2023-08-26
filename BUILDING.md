## Local build with Dockerfile

First of all you need to get the submodules code,
because this project depends on https://github.com/riptano/scribe fork.

```
cd collectd
git submodule init
git submodule update
```

Then you can build locally using `Dockerfile`, for example:

```
docker build -t riptano/collectd:latest .
```

## PR builds

PR builds will happen automatically on every push to PR that is not in the `Draft` state.

## Releases

Tags in format `vx.y.z` are automatically built and published via github actions.
