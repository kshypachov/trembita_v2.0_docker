## Description: ephemeralVolumeRAM

`ephemeralVolumeRAM` refers to temporary volumes implemented via `emptyDir: { medium: "Memory" }`, meaning they are created in **RAM**. These are used to store transient data such as:

- unpacked Java libraries,
- bytecode,
- runtime caches.

---

### Characteristics:

- **Work like tmpfs**: created in memory (RAM), fast, and wiped out on Pod restart.
- **Simple to use** — no PVC or StorageClass required.
- **Created empty** — the application must create any required directory structure.
- **Size-limited** — it is recommended to keep below 100 MB.

---

### Example declaration in `values.yaml`

```yaml
trembita_proxy_pod:
  name: proxy
  image: kshypachov/trembita_jb_uxp-proxy-v1.22.7:v1.0.6
  ephemeralVolumeRAM:
    - name: proxy-java-cache         # arbitrary volume name
      mountPath: /tmp/bc_java/       # mount path inside container
      sizeLimit: "100Mi"             # size limit in RAM
```

> You can define multiple such volumes for different purposes — caching, buffering, etc.

---

### How it works in the template

```yaml
- name: {{ .name }}
  emptyDir:
    medium: Memory
    sizeLimit: {{ .sizeLimit }}
```

---

### Where it is used

These volumes are mounted, for example, in the following components:

- `trembita_proxy_pod`
- `trembita_identity_provider_rest_api_pod`
- `trembita_ocsp_cache_pod`
- `trembita_verifier_pod`

---

### Notes

- These volumes **do not support initialization with data**.
- They are cleared after Pod restarts.
- Using tmpfs reduces disk I/O but is unsuitable for persistent data.

---

**Use `ephemeralVolumeRAM` when you need to store temporary files that do not require persistence.**