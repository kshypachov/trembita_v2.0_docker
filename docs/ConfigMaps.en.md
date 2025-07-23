## Description: ConfigMap

A `ConfigMap` is a Kubernetes resource that allows injecting configuration files into a Pod. A single `ConfigMap` can be mounted into multiple containers simultaneously and used jointly.

This chart uses a **declarative definition model**, consisting of the following steps:

---

### 1. Declaration in `values.yaml`

Each `ConfigMap` is declared under the `trembita_config.configMaps` section. Example:

```yaml
local_ini:                              # Key
  enabled: true                         # enables or disables the ConfigMap
  name: local-ini                       # name of the Kubernetes resource
  mountPath: /etc/uxp/conf.d/local.ini # mount path inside the container
  subPath: local.ini                    # file name inside the ConfigMap
```

---

### 2. Content definition in `trembita-config-maps.yaml`

The `trembita-config-maps.yaml` file contains the template for creating the corresponding Kubernetes resource:

```yaml
{{- if and .enabled .local_ini.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .local_ini.name }}
data:
  {{ default "local.ini" .local_ini.subPath }}: |
    ;[identity-provider]
    ;security-server-client-id = 60997vl7jlgoi53zbyvv2k9iyny1rae2
    ;security-server-client-secret = QTK3fBuPu0v0m2DpvEees0AODujEcX3V
    ;public-client-redirect-uris= https://{{ $.Values.trembita_config.trembita_frontend_pod.ingress.host }}
    ;hostname={{ $.Values.trembita_config.trembita_frontend_pod.ingress.host }}

    ;[message-log]
    ;archive-storage-type = s3
    ;archive-interval=0 * * * * ? *

    ;[message-log-s3]
    ;bucket-name = uxp-messagelog
    ;access-key = scmyyP91huXNGdcGgLUu
    ;secret-key = jFiGQMn8pPngBFUFN1NcrxEjfWPKm11tIolVGmcm
    ;address = http://minio:9000
{{- end }}
```

---

### 3. Mounting into Pod

To mount the `ConfigMap` into a Pod, add its key (e.g., `local_ini`) into the target Pod's `configMaps` section:

```yaml
trembita_configuration_client_pod:
  configMaps:
    - uxp_anchor
    - uxp_license
    - local_ini  # ← added key local_ini
```

> Also make sure `enabled: true` is set for the corresponding key in the `configMaps` section.

---

### Use this technique to add your own `ConfigMap`s into the system.