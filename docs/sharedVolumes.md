## Описание: sharedVolumes

В данном Helm чарте под `sharedVolumes` понимаются **PersistentVolumeClaim (PVC)** ресурсы, использующие `StorageClass`, поддерживающий режим **ReadWriteMany (RWX)** — то есть возможность одновременного подключения к нескольким Pod'ам.

---

### 1. Объявление в `values.yaml`

Каждый shared volume объявляется в секции `sharedVolumes:` с параметрами:

```yaml
sharedVolumes:
  var-lib-uxp-messagelog:       # ← ключ, используемый при подключении к Pod
    enabled: true               # включает создание PVC
    initCopy: false             # выполнять ли копирование данных из init-образа
    size: 2Gi                   # запрашиваемый размер PVC
    mountPath: /var/lib/uxp/messagelog/  # путь монтирования в контейнере
    storageClassName: "longhorn-rwx"     # StorageClass с поддержкой RWX
    accessModes:
      - ReadWriteMany           # режим доступа
```

---

### 2. Генерация PVC в шаблоне `trembita-shared-disk-pvc.yaml`

Для каждого объявленного shared volume автоматически создаётся соответствующий `PersistentVolumeClaim` при установке чарта:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Name }}
  annotations:
    "helm.sh/hook": pre-install  # создаётся только на этапе установки Helm чарта
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: {{ .Size }}
  storageClassName: {{ .StorageClassName }}
```

> Обратите внимание: PVC создаются **только при установке** чарта, благодаря аннотации `helm.sh/hook: pre-install`.

---

### 3. Подключение sharedVolume к Pod

Чтобы подключить shared volume к Pod, необходимо добавить его ключ в секцию `sharedVolumes:` соответствующего Pod-а:

```yaml
trembita_proxy_pod:
  name: proxy
  image: kshypachov/trembita_jb_uxp-proxy-v1.22.7:v1.0.6
  env:
    TZ: Europe/Kyiv
    UXP_TOKENS_PASS: "0:12345,ciplus-78-5:##ADMIN##123456789"
    PKCS11_PROXY_SOCKET: tcp://94.131.252.139:23454
  sharedVolumes:
    - var-lib-uxp-messagelog   # ← подключённый shared volume
```

---

### 4. Особенности

- При `initCopy: true` содержимое копируется из `init`-образа в shared volume.
- Все shared volume-ы создаются до запуска Pod-ов, что гарантирует доступность данных на момент старта.
- Убедитесь, что выбранный `StorageClass` (например, `longhorn-rwx`) поддерживает `ReadWriteMany`.

---

### Используйте данную модель для подключения общих директорий, таких как:
- каталоги с логами
- подписанные транзакции
- глобальные конфигурации
- токены и ключи