# Trembita 2.0 Helm Chart

Этот Helm Chart предназначен для развертывания платформы **Trembita 2.0** в Kubernetes окружении.

---
Данный Helm-чарт использует следующие сущности Kubernetes:

| Компонент                | Описание                                            | Документация                   |
|--------------------------|-----------------------------------------------------|--------------------------------|
| ConfigMap                | Конфигурационные файлы                              | [ConfigMap](docs/ConfigMaps.md) |
| Shared Volumes           | Постоянные хранилища, доступные из нескольких Pod  | [Shared Volumes](docs/sharedVolumes.md) |
| Ephemeral RAM Volumes    | Временные тома в оперативной памяти                | [Ephemeral Volumes](docs/ephemeralVolumes.md) |
| Persistent Storage       | Постоянное хранилище, доступное только одному Pod  | [Persistent Storage](docs/persistentVolume.md) |

## Подготовка

Перед установкой выполните следующие шаги:

### 1. StorageClass с поддержкой ReadWriteMany

Убедитесь, что в вашем кластере доступно хранилище с поддержкой **ReadWriteMany (RWX)**. Это необходимо для корректной работы shared volumes между подами.

> Рекомендуемый и протестированный провайдер: **Longhorn**.

Если вы используете Longhorn, но ещё не настроили RWX StorageClass, вы можете использовать [пример StorageClass](https://github.com/kshypachov/trembita_v2.0_docker/blob/main/longhorn_rwm_storege_class.yaml) из соответствующего репозитория.

---

### 2. Сборка Docker образов

В чарте используются предсобранные образы, размещённые в публичных Docker Registry. **Настоятельно рекомендуется пересобрать их самостоятельно и загрузить в ваш внутренний реестр.**

Исходные Dockerfile находятся в репозитории:

```
https://github.com/kshypachov/trembita_v2.0_separate_components_docker.git
```

---

### 3. DNS инфраструктура

Все компоненты Trembita доступны только по **DNS-именам**. Убедитесь, что в вашей внутренней сети настроен DNS-сервер и доменные имена разрешаются.

---

### 4. Поддержка HTTPS passthrough для mutual TLS (опционально)

Если ваши веб-клиенты должны использовать **взаимную HTTPS-аутентификацию**, убедитесь, что ваш Ingress контроллер поддерживает passthrough:

```yaml
nginx.ingress.kubernetes.io/ssl-passthrough: "true"
```

---

## Установка Helm чарта

### 1. Клонирование репозитория

```bash
git clone https://github.com/kshypachov/trembita_v2.0_docker.git
```

---

### 2. Настройка values.yaml

Редактируйте файл:

```
trembita-1-22-6-ss/values.yaml
```

### 3. Обновите следующие параметры:

> **Важно**: Все образы, указанные ниже, рекомендуется пересобрать и опубликовать в вашем реестре Docker.

| Параметр | Образ | Назначение                                                                            |
|---------|-------|---------------------------------------------------------------------------------------|
| `trembita_config.init_jobs.trembita_postgres.image` | db_init_container | Инициализация базы данных                                                             |
| `trembita_config.init_jobs.trembita_volumes.image` | uxp-main | Создание структуры файловой системы                                                   |
| `trembita_config.trembita_configuration_client_pod.image` | uxp-configuration-client | Служба загружает глобальную конфигурацию из источников указанных в якоре конфигурации |
| `trembita_config.trembita_message_log_archiver_pod.image` | uxp-message-log-archiver | Архивирование транзакций в файловую систему или s3 хранилище                          |
| `trembita_config.trembita_identity_provider_rest_api_pod.image` | uxp-identity-provider-rest-api | API OAuth авторизация пользователей веб интерфейса                                    |
| `trembita_config.trembita_ocsp_cache_pod.image` | uxp-ocsp-cache | Кеширование OCSP ответов                                                              |
| `trembita_config.trembita_verifier_pod.image` | uxp-verifier | Проверка транзакций                                                                   |
| `trembita_config.trembita_seg_rest_api_pod.image` | uxp-seg-rest-api | REST API для управления ШБО Trembita 2.0                                              |
| `trembita_config.trembita_proxy_pod.image` | uxp-proxy | Обработка транзакций (шифрование, дешифрование, подпись)                              |
| `trembita_config.trembita_monitor_pod.image` | uxp-monitor | Мониторинг, агрегирование транзакционных логов                                        |
| `trembita_config.trembita_frontend_pod.image` | uxp-frontend | Веб-интерфейс                                                                         |
| `trembita_config.trembita_postgresql_pod.image` | postgres:16 | База данных                                                                           |

---

### Дополнительно:

#### Использование HSM (Cipher или Gryda-301)

- Добавьте в `env` переменную окружения в секциях `trembita_seg_rest_api_pod:` и `trembita_proxy_pod:` :

```yaml
PKCS11_PROXY_SOCKET: tcp://192.168.252.139:12345
```

- Если используется **Gryda-301**, раскомментируйте в секциях `trembita_seg_rest_api_pod:` и `trembita_proxy_pod:` в `configMaps` параметр `osplm_ini`.
- Отредактируйте конфиг мап `osplm_ini` - вписав коректные значения вашей **Gryda-301** (как работают [конфиг мап](docs/ConfigMaps.md) в данном чарте)

#### Передача токенов в proxy:

- Добавьте в `env` переменную окружения в секциях `trembita_seg_rest_api_pod:` и `trembita_proxy_pod:` :

```yaml
UXP_TOKENS_PASS: "0:12345,ciplus-78-5:##ADMIN##123456789"
```

> Формат передачи описан здесь: https://github.com/kshypachov/seg_init_tokens.git

---

### Настройка Ingress

#### Proxy:
```yaml
trembita_proxy_pod.ingress:
  host: api.trembita.office
  secure_host: secure-api.trembita.office
```

> Замените на актуальные домены вашей инфраструктуры.

#### Frontend:
```yaml
trembita_frontend_pod.ingress.host: trembita.office
```

---

### Хранилище PostgreSQL

```yaml
trembita_postgresql_pod.persistentStorage.size: 5Gi
```

Обычно достаточно 5ГБ при выгрузке транзакций в S3 и очистке локального хранилища.

---

### sharedVolumes

Общие тома, которые подключаются к нескольким подам.

- `var-lib-uxp-messagelog` — содержит транзакции и временные файлы.  
  > Не изменяйте `initCopy`, `mountPath`, `storageClassName`.

- `etc-uxp-globalconf`, `etc-uxp-signer` — копируются с образа на этапе инициализации.

---

### MinIO

Настроен как отдельный модуль (Bitnami Helm chart).

Подробнее: https://artifacthub.io/packages/helm/bitnami/minio

Пример конфигурации:
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