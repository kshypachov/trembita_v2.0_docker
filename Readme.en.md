# Trembita 2.0 Helm Chart

This Helm Chart is intended for deploying the **Trembita 2.0** platform in a Kubernetes environment.

---

This Helm Chart utilizes the following Kubernetes components:

| Component               | Description                                                  | Documentation                       |
|------------------------|--------------------------------------------------------------|--------------------------------------|
| ConfigMap              | Configuration files                                          | [ConfigMap](docs/ConfigMaps.md)      |
| Shared Volumes         | Persistent storage accessible from multiple Pods             | [Shared Volumes](docs/sharedVolumes.ua.md) |
| Ephemeral RAM Volumes  | Temporary in-memory volumes                                  | [Ephemeral Volumes](docs/ephemeralVolumes.ua.md) |
| Persistent Storage     | Persistent storage accessible by a single Pod                | [Persistent Storage](docs/persistentVolume.ua.md) |

## Preparation

Before installation, complete the following steps:

### 1. StorageClass with ReadWriteMany support

Ensure that your cluster supports a **ReadWriteMany (RWX)**-capable storage provider. This is required for proper shared volume functionality between pods.

> Recommended and tested provider: **Longhorn**.

If you are using Longhorn but haven't configured an RWX StorageClass yet, you can use [this StorageClass example](https://github.com/kshypachov/trembita_v2.0_docker/blob/main/longhorn_rwm_storege_class.yaml) from the corresponding repository.

---

### 2. Docker image build

The chart uses prebuilt images published in public Docker registries. **It is strongly recommended to rebuild them yourself and upload to your internal registry.**

The original Dockerfiles are located in this repository:

```
https://github.com/kshypachov/trembita_v2.0_separate_components_docker.git
```

---

### 3. DNS infrastructure

All Trembita components are accessible only via **DNS hostnames**. Ensure that a DNS server is configured in your internal network and domain names are resolvable.

---

### 4. HTTPS passthrough for mutual TLS (optional)

If your web clients require **mutual HTTPS authentication**, ensure that your Ingress controller supports passthrough:

```yaml
nginx.ingress.kubernetes.io/ssl-passthrough: "true"
```

---

## Helm Chart Installation

### 1. Clone the repository

```bash
git clone https://github.com/kshypachov/trembita_v2.0_docker.git
```

---

### 2. Configure values.yaml

Edit the following file:

```
trembita-1-22-6-ss/values.yaml
```

### 3. Update the following parameters:

> **Important**: All images listed below should be rebuilt and published to your private Docker registry.

| Parameter | Image | Purpose |
|----------|-------|---------|
| `trembita_config.init_jobs.trembita_postgres.image` | db_init_container | Database initialization |
| `trembita_config.init_jobs.trembita_volumes.image` | uxp-main | Filesystem structure creation |
| `trembita_config.trembita_configuration_client_pod.image` | uxp-configuration-client | Downloads global configuration from defined sources |
| `trembita_config.trembita_message_log_archiver_pod.image` | uxp-message-log-archiver | Archives transactions to the filesystem or S3 |
| `trembita_config.trembita_identity_provider_rest_api_pod.image` | uxp-identity-provider-rest-api | OAuth API for web interface user authentication |
| `trembita_config.trembita_ocsp_cache_pod.image` | uxp-ocsp-cache | OCSP response caching |
| `trembita_config.trembita_verifier_pod.image` | uxp-verifier | Transaction verification |
| `trembita_config.trembita_seg_rest_api_pod.image` | uxp-seg-rest-api | REST API for managing Trembita 2.0 SEG |
| `trembita_config.trembita_proxy_pod.image` | uxp-proxy | Handles transactions (encryption, decryption, signing) |
| `trembita_config.trembita_monitor_pod.image` | uxp-monitor | Monitoring and log aggregation |
| `trembita_config.trembita_frontend_pod.image` | uxp-frontend | Web interface |
| `trembita_config.trembita_postgresql_pod.image` | postgres:16 | Database |

---

### Additional:

#### HSM Support (Cipher or Gryda-301)

- Add the following environment variable under `trembita_seg_rest_api_pod:` and `trembita_proxy_pod:`:

```yaml
PKCS11_PROXY_SOCKET: tcp://192.168.252.139:12345
```

- If using **Gryda-301**, uncomment the `osplm_ini` configMap parameter in both `trembita_seg_rest_api_pod:` and `trembita_proxy_pod:`.
- Edit the `osplm_ini` configMap with the correct values for your **Gryda-301** (see [ConfigMap documentation](docs/ConfigMaps.md)).

#### Token passthrough to proxy:

- Add this environment variable under `trembita_seg_rest_api_pod:` and `trembita_proxy_pod:`:

```yaml
UXP_TOKENS_PASS: "0:12345,ciplus-78-5:##ADMIN##123456789"
```

> Format details available at: https://github.com/kshypachov/seg_init_tokens.git

---

### Ingress Configuration

#### Proxy:
```yaml
trembita_proxy_pod.ingress:
  host: api.trembita.office
  secure_host: secure-api.trembita.office
```

> Replace with your actual domain names.

#### Frontend:
```yaml
trembita_frontend_pod.ingress.host: trembita.office
```

---

### PostgreSQL Storage

```yaml
trembita_postgresql_pod.persistentStorage.size: 5Gi
```

5GB is usually sufficient if transactions are exported to S3 and local storage is cleaned up regularly.

---

### sharedVolumes

Shared volumes mounted by multiple pods.

- `var-lib-uxp-messagelog` — stores transactions and temporary files.  
  > Do not modify `initCopy`, `mountPath`, or `storageClassName`.

- `etc-uxp-globalconf`, `etc-uxp-signer` — copied from the image during initialization.

---

### MinIO

Configured as a separate module (Bitnami Helm chart).

More info: https://artifacthub.io/packages/helm/bitnami/minio

Example configuration:
```yaml
minio:
  fullnameOverride: minio
  auth:
    rootUser: minioadmin
    rootPassword: minioadmin
  defaultBuckets: uxp-messagelog
  mode: standalone
  persistence:
    enabled: true
    size: 1Gi
  ingress:
    enabled: true
    ingressClassName: "nginx"
    hostname: minio.trembita.office
  apiIngress:
    enabled: true
    ingressClassName: "nginx"
    hostname: api.minio.trembita.office
```