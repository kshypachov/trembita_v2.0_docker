## Description: persistentStorage

`persistentStorage` refers to persistent storage mounted into a Pod using a Kubernetes `PersistentVolumeClaim`, designed for **exclusive use** — i.e., accessible by only one Pod at a time. Unlike `sharedVolumes`, `persistentStorage` cannot be mounted simultaneously in multiple Pods.

---

### Current Limitations:

- Currently used **only in `trembita_postgresql_pod`**.
- Also used in MinIO, but its configuration is encapsulated within the Bitnami Helm chart and **is not described in this documentation**.
- **Not a universal solution** — requires manual addition of templates for each new Pod.

---

### Example configuration in `values.yaml`

```yaml
trembita_postgresql_pod:
  name: postgres
  image: postgres:16
  persistentStorage:
    - name: postgres                       # unique name for PVC
      mountPath: /var/lib/postgresql/data # container mount path
      size: 1Gi                            # PVC size
      storageClass: ""                    # optional StorageClass (empty for default)
```

---

### PVC Creation

PVC creation is handled by the template:

```
templates/postgres/postgresql-pvc.yaml
```

> To add `persistentStorage` to another component:
> 1. Copy `postgresql-pvc.yaml` to the target Pod’s directory.
> 2. Rename the file.
> 3. Modify the template to read values from your component's `values.yaml`.

---

### Access Modes

The PVC is created with the following access mode:

```yaml
accessModes:
  - ReadWriteOnce
```

This means the volume **can only be used by a single Pod at a time**.

---

### Installation Behavior

PVC creation occurs only during the Helm chart installation due to the annotation:

```yaml
annotations:
  "helm.sh/hook": pre-install
```

If you are upgrading an already installed chart, **the PVC will not be created automatically**.

---

### Summary

- `persistentStorage` is suited for components that require **dedicated storage**, such as PostgreSQL.