#!/bin/bash
set -e

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