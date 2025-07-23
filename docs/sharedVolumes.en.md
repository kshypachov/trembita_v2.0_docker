## Description: sharedVolumes

In this Helm chart, `sharedVolumes` refer to **PersistentVolumeClaim (PVC)** resources that utilize a `StorageClass` supporting **ReadWriteMany (RWX)** mode — allowing simultaneous access by multiple Pods.

---

### 1. Declaration in `values.yaml`

Each shared volume is declared under the `sharedVolumes:` section with the following parameters:

```yaml
sharedVolumes:
  var-lib-uxp-messagelog:       # ← key used for Pod attachment
    enabled: true               # enables PVC creation
    initCopy: false             # whether to copy data from init image
    size: 2Gi                   # requested PVC size
    mountPath: /var/lib/uxp/messagelog/  # mount path in the container
    storageClassName: "longhorn-rwx"     # RWX-compatible StorageClass
    accessModes:
      - ReadWriteMany           # access mode
```

---

### 2. PVC generation in `trembita-shared-disk-pvc.yaml` template

For each declared shared volume, a corresponding `PersistentVolumeClaim` is automatically created during chart installation:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Name }}
  annotations:
    "helm.sh/hook": pre-install  # created only during Helm chart installation
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: {{ .Size }}
  storageClassName: {{ .StorageClassName }}
```

> Note: PVCs are created **only during installation**, thanks to the `helm.sh/hook: pre-install` annotation.

---

### 3. Attaching sharedVolume to a Pod

To attach a shared volume to a Pod, add its key to the Pod’s `sharedVolumes:` section:

```yaml
trembita_proxy_pod:
  name: proxy
  image: kshypachov/trembita_jb_uxp-proxy-v1.22.7:v1.0.6
  env:
    TZ: Europe/Kyiv
    UXP_TOKENS_PASS: "0:12345,ciplus-78-5:##ADMIN##123456789"
    PKCS11_PROXY_SOCKET: tcp://94.131.252.139:23454
  sharedVolumes:
    - var-lib-uxp-messagelog   # ← attached shared volume
```

---

### 4. Key Features

- If `initCopy: true`, contents are copied from the `init` image into the shared volume.
- All shared volumes are created before Pods start, ensuring data availability at launch time.
- Ensure that the specified `StorageClass` (e.g., `longhorn-rwx`) supports `ReadWriteMany`.

---

### Use this model to mount shared directories such as:
- log directories
- signed transactions
- global configurations
- tokens and key material