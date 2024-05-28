#!/bin/sh

set -e

source ./utils.sh

log_info "run dbdump version $VERSION revision $GIT_REVISION"

mysql_connect="--host=${MYSQL_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD}"

set +e
mysql $mysql_connect -e "SHOW DATABASES; USE serlo; SHOW TABLES;" | grep uuid >/dev/null 2>/dev/null
if [[ $? != 0 ]]; then
    log_info "database serlo does not exist; nothing to dump"
    exit 0
fi
set -e

log_info "dump serlo.org database - start"
log_info "dump legacy serlo database schema"

mysqldump $mysql_connect --no-data --lock-tables=false --add-drop-database serlo >mysql.sql

mysqldump $mysql_connect --no-create-info --lock-tables=false --add-locks --ignore-table=serlo.user serlo >>mysql.sql

mysql $mysql_connect --batch -e "SELECT id, CONCAT(@rn:=@rn+1, '@localhost') AS email, username, '8a534960a8a4c8e348150a0ae3c7f4b857bfead4f02c8cbf0d' AS password, logins, date, CONCAT(@rn:=@rn+1, '') AS token, last_login, description FROM user, (select @rn:=2) r;" serlo >user.csv

log_info "dump kratos identities data"
export PGPASSWORD=$POSTGRES_PASSWORD_READONLY
pg_dump --host=${POSTGRES_HOST} --user=serlo_readonly kratos >temp.sql
pg_ctl start -D /var/lib/postgresql/data
psql --quiet -c "CREATE user serlo;"
psql --quiet -c "CREATE user serlo_readonly;"
psql --quiet -c "CREATE database kratos;"
psql --quiet -c "GRANT ALL PRIVILEGES ON DATABASE kratos TO serlo;"
psql --quiet -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO serlo_readonly;"
psql -d kratos <temp.sql
rm temp.sql

psql --quiet kratos -c "UPDATE identities SET traits = JSONB_SET(traits, '{email}', TO_JSONB(CONCAT(id, '@localhost')));"
psql --quiet kratos -c "UPDATE identities SET traits = JSONB_SET(traits, '{interest}', '\"\"') where traits ->> 'interest' != 'teacher';"
psql --quiet kratos -c "UPDATE identity_credentials SET config = '{\"hashed_password\": \"\$sha1\$pf=e1NBTFR9e1BBU1NXT1JEfQ==\$YTQwYzEwY2ZlNA==\$hTlqikjjSFoK43S4V7+t8CyMvw0=\"}';"
psql --quiet kratos -c "UPDATE identity_verifiable_addresses SET value = CONCAT(identity_id, '@localhost');"
psql --quiet kratos -c "UPDATE identity_recovery_addresses SET value = CONCAT(identity_id, '@localhost');"
psql --quiet kratos -c "UPDATE identity_credential_identifiers SET identifier = CONCAT(ic.identity_id, '@localhost') FROM (select id, identity_id FROM identity_credentials) AS ic where ic.id = identity_credential_id and identifier LIKE '%@%';"
psql --quiet kratos -c "TRUNCATE sessions, continuity_containers, courier_messages, identity_verification_codes, identity_recovery_codes, identity_recovery_tokens, identity_verification_tokens, selfservice_errors, selfservice_login_flows, selfservice_recovery_flows, selfservice_registration_flows, selfservice_settings_flows, selfservice_verification_flows, session_devices, session_token_exchanges CASCADE;"
pg_dump kratos >kratos.sql

log_info "compress database dump"
rm -f *.zip
zip "dump-$(date -I)".zip mysql.sql user.csv kratos.sql >/dev/null

cat <<EOF | gcloud auth activate-service-account --key-file=-
${BUCKET_SERVICE_ACCOUNT_KEY}
EOF
gsutil cp dump-*.zip "${BUCKET_URL}"
log_info "latest dump ${BUCKET_URL} uploaded to serlo-shared"

log_info "dump of serlo.org database - end"
