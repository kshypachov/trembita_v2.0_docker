#!/bin/bash

log() { echo "$(date --utc -Iseconds) INFO [entrypoint] $*"; }


## Edit password for web acess user
if [  -n "$UXPADMIN_PASS" ]
then
   echo "UXPADMIN_PASS variable set, changing pass"
   echo "uxpadmin:$UXPADMIN_PASS" | chpasswd
   unset UXPADMIN_PASS
fi

## Edit main config for connect to DB postgres

CONFIG_FILE="/etc/uxp/db.properties"

# Список ключей и переменные окружения, которые их заменяют
declare -A PARAMS=(
  ["serverconf.hibernate.connection.username"]="SERVERCONF_DB_USER"
  ["serverconf.hibernate.connection.password"]="SERVERCONF_DB_PASSWORD"
  ["serverconf.hibernate.connection.url"]="SERVERCONF_DB_URL"

  ["messagelog-metadata.hibernate.connection.username"]="MESSAGELOG_DB_USER"
  ["messagelog-metadata.hibernate.connection.password"]="MESSAGELOG_DB_PASSWORD"
  ["messagelog-metadata.hibernate.connection.url"]="MESSAGELOG_DB_URL"

  ["identity-provider.hibernate.connection.username"]="IDENTITYPROVIDER_DB_USER"
  ["identity-provider.hibernate.connection.password"]="IDENTITYPROVIDER_DB_PASSWORD"
  ["identity-provider.hibernate.connection.url"]="IDENTITYPROVIDER_DB_URL"

  ["op-monitor.hibernate.connection.username"]="OPMONITOR_DB_USER"
  ["op-monitor.hibernate.connection.password"]="OPMONITOR_DB_PASSWORD"
  ["op-monitor.hibernate.connection.url"]="OPMONITOR_DB_URL"
)

# Обработка каждой пары
for key in "${!PARAMS[@]}"; do
  env_var="${PARAMS[$key]}"
  new_value="${!env_var}"  # Получаем значение переменной окружения
  unset env_var

  if [ -n "$new_value" ]; then
    # Экранируем спецсимволы для sed
    escaped_value=$(printf '%s\n' "$new_value" | sed -e 's/[\/&]/\\&/g')
    sed -i "s|^$key *=.*|$key = $escaped_value|" "$CONFIG_FILE"
  fi
done

if [  -n "$UXP_IDENTETY_DOMAIN" ]; then
  echo "test"
fi

log "Starting supervisord"
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf