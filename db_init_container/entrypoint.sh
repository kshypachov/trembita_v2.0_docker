#!/bin/bash
set -e

#export PGHOST = postgres
#export PGPORT = 5432

# Путь к файлу db.properties
DB_PROPERTIES="/etc/uxp/db.properties"

# Функция для извлечения значения из db.properties
get_value() {
    grep -E "^$1\s*=" "$DB_PROPERTIES" | cut -d'=' -f2- | xargs
}

# Основные параметры подключения
export PGHOST=$(get_value "serverconf.hibernate.connection.url" | sed -E 's|jdbc:postgresql://([^:/]+):([0-9]+)/.*|\1|')
export PGPORT=$(get_value "serverconf.hibernate.connection.url" | sed -E 's|jdbc:postgresql://([^:/]+):([0-9]+)/.*|\2|')

# Root-пользователь — не указан в файле, нужно задать отдельно
#export PGROOT_USER="postgres"
#export PGROOT_PASSWORD="<заполни_вручную_или_из_секрета>"

# Пользователи и пароли
export SERVERCONF_DB_USER=$(get_value "serverconf.hibernate.connection.username")
export SERVERCONF_DB_PASS=$(get_value "serverconf.hibernate.connection.password")

export MESSAGELOG_DB_USER=$(get_value "messagelog-metadata.hibernate.connection.username")
export MESSAGELOG_DB_PASS=$(get_value "messagelog-metadata.hibernate.connection.password")

export IDENTITY_DB_USER=$(get_value "identity-provider.hibernate.connection.username")
export IDENTITY_DB_PASS=$(get_value "identity-provider.hibernate.connection.password")

export OPMONITOR_DB_USER=$(get_value "op-monitor.hibernate.connection.username")
export OPMONITOR_DB_PASS=$(get_value "op-monitor.hibernate.connection.password")

# Путь к файлу db.monitor-admin
DB_PROPERTIES="/etc/uxp/db.monitor-admin"

# Админ-пользователь для op-monitor — в файле не задан
export OPMONITOR_ADMIN_DB_USER=$(get_value "op-monitor-admin.username")
export OPMONITOR_ADMIN_DB_PASS=$(get_value "op-monitor-admin.password")

# Вывод всех переменных
echo "PGHOST=$PGHOST"
echo "PGPORT=$PGPORT"
echo "PGROOT_USER=$PGROOT_USER"
echo "PGROOT_PASSWORD=$PGROOT_PASSWORD"
echo "SERVERCONF_DB_USER=$SERVERCONF_DB_USER"
echo "SERVERCONF_DB_PASS=$SERVERCONF_DB_PASS"
echo "MESSAGELOG_DB_USER=$MESSAGELOG_DB_USER"
echo "MESSAGELOG_DB_PASS=$MESSAGELOG_DB_PASS"
echo "IDENTITY_DB_USER=$IDENTITY_DB_USER"
echo "IDENTITY_DB_PASS=$IDENTITY_DB_PASS"
echo "OPMONITOR_DB_USER=$OPMONITOR_DB_USER"
echo "OPMONITOR_DB_PASS=$OPMONITOR_DB_PASS"
echo "OPMONITOR_ADMIN_DB_USER=$OPMONITOR_ADMIN_DB_USER"
echo "OPMONITOR_ADMIN_DB_PASS=$OPMONITOR_ADMIN_DB_PASS"


# Проверка обязательных переменных окружения
REQUIRED_VARS=(
  PGHOST PGPORT PGROOT_USER PGROOT_PASSWORD
  SERVERCONF_DB_USER SERVERCONF_DB_PASS
  MESSAGELOG_DB_USER MESSAGELOG_DB_PASS
  IDENTITY_DB_USER IDENTITY_DB_PASS
  OPMONITOR_DB_USER OPMONITOR_DB_PASS
  OPMONITOR_ADMIN_DB_USER OPMONITOR_ADMIN_DB_PASS
)

echo "🔍 Checking required environment variables..."
for VAR in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!VAR}" ]]; then
    echo "❌ ERROR: Required environment variable $VAR is not set"
    exit 1
  fi
done

# Ждём доступности PostgreSQL
echo "⌛ Waiting for PostgreSQL to become available at $PGHOST:$PGPORT..."

for i in {1..60}; do
  if pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGROOT_USER" >/dev/null 2>&1; then
    echo "✅ PostgreSQL is ready"
    break
  fi
  echo "⏳ PostgreSQL not ready yet... ($i/60)"
  sleep 2
done

# Повторная проверка — если за 120 сек не стал доступен
if ! pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGROOT_USER"; then
  echo "❌ PostgreSQL is still not available after timeout. Exiting."
  exit 1
fi

echo "✅ All required environment variables are present."
export PGPASSWORD="$PGROOT_PASSWORD"

# Список баз, пользователей и паролей
declare -A DBS=(
  [serverconf]="${SERVERCONF_DB_USER}:${SERVERCONF_DB_PASS}"
  [messagelog-metadata]="${MESSAGELOG_DB_USER}:${MESSAGELOG_DB_PASS}"
  [identity-provider]="${IDENTITY_DB_USER}:${IDENTITY_DB_PASS}"
  [op-monitor]="${OPMONITOR_DB_USER}:${OPMONITOR_DB_PASS}"
)

echo "🔧 Creating user '$OPMONITOR_DB_USER'"
psql -h "$PGHOST" -p "$PGPORT" -U "$PGROOT_USER" -c \
      "CREATE ROLE \"$OPMONITOR_ADMIN_DB_USER\" LOGIN PASSWORD '$OPMONITOR_ADMIN_DB_PASS';" # костыль для пользователя не из конфига

# Создать пользователя Цикл по всем пользователям
for DB in "${!DBS[@]}"; do
  USER_PASS="${DBS[$DB]}"
  USER="${USER_PASS%%:*}"
  PASS="${USER_PASS##*:}"

  echo "🔧 Creating user '$USER'"

  # Проверка: существует ли пользователь
  USER_EXISTS=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGROOT_USER" -tAc \
    "SELECT 1 FROM pg_roles WHERE rolname = '$USER';")

  if [ "$USER_EXISTS" != "1" ]; then
    echo "➕ Creating user '$USER'..."
    psql -h "$PGHOST" -p "$PGPORT" -U "$PGROOT_USER" -c \
      "CREATE ROLE \"$USER\" LOGIN PASSWORD '$PASS';"
  else
    echo "✔️ User '$USER' already exists."
  fi
done


# Создание баз данных
for DB in "${!DBS[@]}"; do
  USER_PASS="${DBS[$DB]}"
  USER="${USER_PASS%%:*}"
  PASS="${USER_PASS##*:}"

  DB_EXISTS=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGROOT_USER" -tAc "SELECT 1 FROM pg_database WHERE datname = '$DB'")
  if [ "$DB_EXISTS" != "1" ]; then
    echo "📦 Creating database $DB..."
    psql -h "$PGHOST" -p "$PGPORT" -U "$PGROOT_USER" -c "CREATE DATABASE \"$DB\" OWNER $USER;"
  fi
done

# Импорт SQL дампов
echo "⬇️ Importing SQL dumps..."

PGPASSWORD="$PGROOT_PASSWORD" psql -h "$PGHOST" -p "$PGPORT" -U "$PGROOT_USER" -d serverconf < /serverconf.sql
PGPASSWORD="$PGROOT_PASSWORD" psql -h "$PGHOST" -p "$PGPORT" -U "$PGROOT_USER" -d messagelog-metadata < /messagelog-metadata.sql
PGPASSWORD="$PGROOT_PASSWORD" psql -h "$PGHOST" -p "$PGPORT" -U "$PGROOT_USER" -d identity-provider < /identity-provider.sql
PGPASSWORD="$PGROOT_PASSWORD" psql -h "$PGHOST" -p "$PGPORT" -U "$PGROOT_USER" -d op-monitor < /op-monitor.sql

echo "✅ All databases initialized successfully."