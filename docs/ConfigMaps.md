## Опис: ConfigMap

`ConfigMap` — це сутність Kubernetes, яка дозволяє передавати всередину Pod конфігураційні файли. Один `ConfigMap` може монтуватись одночасно в декілька контейнерів та використовуватись разом.

В даному чарті застосовується **модель оголошення та опису**

---

### 1. Оголошення в `values.yaml`

Кожен `ConfigMap` оголошується в секції `trembita_config.configMaps`. 
Наприклад:

```yaml
local_ini:                              # Ключ 
  enabled: true                         # включает или отключает конфиг-мап
  name: local-ini                       # имя для Kubernetes ресурса
  mountPath: /etc/uxp/conf.d/local.ini # путь монтирования в контейнер
  subPath: local.ini                   # имя файла внутри конфиг-мапа
```

---

### 2. Визначення вмісту в `trembita-config-maps.yaml`

Файл `trembita-config-maps.yaml` містить шаблон для створення відповідного Kubernetes-ресурсу:

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

### 3. Підключення до Pod

Для того щоб  `ConfigMap` був змонтований в Pod, його ключ (наприклад `local_ini`) необхідно додати в секцію `configMaps` необхідного Pod:

```yaml
trembita_configuration_client_pod:
  configMaps:
    - uxp_anchor
    - uxp_license
    - local_ini  # ← добавлен ключ local_ini
```

> **Важливо!** Також необхідно переконатись що `enabled: true` для відповідного ключа в секції `configMaps`.

---

