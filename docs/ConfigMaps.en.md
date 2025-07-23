## Описание: ConfigMap

`ConfigMap` — это сущность Kubernetes, которая позволяет передавать внутрь Pod конфигурационные файлы. Один `ConfigMap` может монтироваться одновременно в несколько контейнеров и использоваться совместно.

В данном чарте применяется **модель объявления и описания**:

---

### 1. Объявление в `values.yaml`

Каждый `ConfigMap` объявляется в секции `trembita_config.configMaps`. Пример:

```yaml
local_ini:                              # Ключ 
  enabled: true                         # включает или отключает конфиг-мап
  name: local-ini                       # имя для Kubernetes ресурса
  mountPath: /etc/uxp/conf.d/local.ini # путь монтирования в контейнер
  subPath: local.ini                   # имя файла внутри конфиг-мапа
```

---

### 2. Определение содержимого в `trembita-config-maps.yaml`

Файл `trembita-config-maps.yaml` содержит шаблон создания соответствующего Kubernetes ресурса:

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

### 3. Подключение к Pod

Чтобы `ConfigMap` был смонтирован в Pod, его ключ (например `local_ini`) нужно добавить в секцию `configMaps` нужного Pod-а:

```yaml
trembita_configuration_client_pod:
  configMaps:
    - uxp_anchor
    - uxp_license
    - local_ini  # ← добавлен ключ local_ini
```

> Также убедитесь, что `enabled: true` для соответствующего ключа в секции `configMaps`.

---

### Используйте эту технику для добавления собственных `ConfigMap`-ов в систему.