# uxp-configuration-client Kubernetes Deployment

This directory contains templates for deploying the `uxp-configuration-client` service in a Kubernetes cluster.

## Description

The `configuration-client.yaml` template defines a `Deployment` resource consisting of a single `Pod` with two containers:

- **sidecar** — used to proxy the local port;
- **uxp-configuration-client** — the main Java application responsible for downloading and processing the X-Road (Trembita) global configuration.

Since the main container listens on **port 5666 bound to interface 127.0.0.1**, it is not directly accessible from outside. To resolve this, a sidecar container using `socat` is employed to proxy:

```
0.0.0.0:6666 → 127.0.0.1:5666
```

This allows other components in the cluster to access port 5666 via a service listening on port 6666.

## Service

The `configuration-client-admin-port-service.yaml` file defines a Kubernetes `Service` that provides access to the admin port of the container via `socat`.

## Configuration Features

- The main Java application is launched with explicitly defined `command` and `args` parameters, making it easy to document and modify the configuration without rebuilding the container.
- The container runs with a **read-only** filesystem. For proper operation, external volumes must be mounted:
  - For Java temporary files and the `javacpp` library (`/tmp/java`, `/var/tmp/uxp/`);
  - For storing the downloaded global configuration.

## Resources

### sidecar (socat)

| Parameter | Value                  |
|----------|------------------------|
| CPU      | 10m (request), 20m (limit) |
| Memory   | 32Mi (request), 64Mi (limit) |
| Port     | 6666                   |

### uxp-configuration-client

| Parameter | Value                     |
|----------|---------------------------|
| CPU      | 100m (request), 200m (limit) |
| Memory   | 128Mi (request), 256Mi (limit) |
| Port     | 5666                      |

## Purpose

This service is used to download the global X-Road configuration and can be accessed by other system services through the proxied admin port.

---

**Note:** The `configuration-client.jar` startup command includes additional dependencies passed via `-cp`, such as `cipher-jce-provider`, `ciplus-jce`, and others.

```bash
java -Xmx50m \
     -XX:MaxMetaspaceSize=70m \
     -XX:+UseG1GC \
     -Xshare:on \
     -Duxp.configuration-client.port=5665 \
     ...
     ee.cyber.uxp.common.conf.globalconf.ConfigurationClientMain
```