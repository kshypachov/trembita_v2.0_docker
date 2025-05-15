#!/bin/bash
set -e

# Проверка обязательных переменных окружения
REQUIRED_VARS=(
  PGHOST PGPORT PGROOT_USER PGROOT_PASSWORD
  SERVERCONF_DB_USER SERVERCONF_DB_PASS
  MESSAGELOG_DB_USER MESSAGELOG_DB_PASS
  IDENTITY_DB_USER IDENTITY_DB_PASS
  OPMONITOR_DB_USER OPMONITOR_DB_PASS
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

# Создание пользователей и баз данных
for DB in "${!DBS[@]}"; do
  USER_PASS="${DBS[$DB]}"
  USER="${USER_PASS%%:*}"
  PASS="${USER_PASS##*:}"

  echo "🔧 Creating user '$USER' and database '$DB'..."

  # Создать пользователя (через DO блок)
  psql -h "$PGHOST" -p "$PGPORT" -U "$PGROOT_USER" -v ON_ERROR_STOP=1 <<-EOSQL
    DO \$\$
    BEGIN
      IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = '$USER'
      ) THEN
        CREATE ROLE $USER LOGIN PASSWORD '$PASS';
      END IF;
    END
    \$\$;
EOSQL

  # Создать базу — вне DO
  DB_EXISTS=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGROOT_USER" -tAc "SELECT 1 FROM pg_database WHERE datname = '$DB'")
  if [ "$DB_EXISTS" != "1" ]; then
    echo "📦 Creating database $DB..."
    psql -h "$PGHOST" -p "$PGPORT" -U "$PGROOT_USER" -c "CREATE DATABASE \"$DB\" OWNER $USER;"
  else
    echo "ℹ️ Database $DB already exists."
  fi

  # Выдать права
  psql -h "$PGHOST" -p "$PGPORT" -U "$PGROOT_USER" -c "GRANT ALL PRIVILEGES ON DATABASE \"$DB\" TO $USER;"
done

# Импорт SQL дампов
echo "⬇️ Importing SQL dumps..."

psql -h "$PGHOST" -p "$PGPORT" -U "$SERVERCONF_DB_USER"      -d serverconf            < /serverconf.sql
psql -h "$PGHOST" -p "$PGPORT" -U "$MESSAGELOG_DB_USER"      -d messagelog-metadata   < /messagelog-metadata.sql
psql -h "$PGHOST" -p "$PGPORT" -U "$IDENTITY_DB_USER"        -d identity-provider     < /identity-provider.sql
psql -h "$PGHOST" -p "$PGPORT" -U "$OPMONITOR_DB_USER"       -d op-monitor            < /op-monitor.sql

echo "✅ All databases initialized successfully."