#!/bin/sh

set -e

source ./utils.sh

log_info "run dbsetup version $VERSION revision $GIT_REVISION"

# add nameserver as currently alpine images dns seems not to work properly in GKE
cat /etc/resolv.conf | grep 1.1.1.1 || printf "\nnameserver 1.1.1.1\n" >>/etc/resolv.conf

mysql_connect="--host=${MYSQL_HOST} --port=${MYSQL_PORT} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD}"

log_info "wait for mysql database to be ready"
until mysql $mysql_connect -e "SHOW DATABASES" >/dev/null 2>/dev/null; do
    log_warn "could not find mysql server - retry in 10 seconds"
    sleep 10
done

log_info "create serlo database if it's not there yet"
mysql $mysql_connect -e "CREATE DATABASE IF NOT EXISTS serlo"

[ -z "GCLOUD_BUCKET_URL" ] && {
    log_fatal "GCLOUD_BUCKET_URL not given"
    exit 1
}

echo $GCLOUD_SERVICE_ACCOUNT_KEY >/tmp/service_account_key.json
gcloud auth activate-service-account ${GCLOUD_SERVICE_ACCOUNT_NAME} --key-file /tmp/service_account_key.json
newest_dump_uri=$(gsutil ls -l gs://anonymous-data | grep dump | sort -rk 2 | head -n 1 | awk '{ print $3 }')
[ -z "$newest_dump_uri" ] && {
    log_fatal "no database dump available in gs://anonymous-data"
    exit 1
}
newest_dump=$(basename $newest_dump_uri)
[ -f "/tmp/$newest_dump" ] && exit 0

gsutil cp $newest_dump_uri "/tmp/$newest_dump"
log_info "downloaded newest dump $newest_dump"
unzip -o "/tmp/$newest_dump" -d /tmp || {
    log_fatal "unzip of dump file failed"
    exit 1
}
mysql $mysql_connect serlo <"/tmp/mysql.sql" || {
    log_fatal "import of dump failed"
    exit 1
}
mysql $mysql_connect -e "LOAD DATA LOCAL INFILE '/tmp/user.csv' INTO TABLE user FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;" serlo || {
    log_fatal "import of dump failed"
    exit 1
}
log_info "imported serlo database dump $newest_dump"

export PGPASSWORD=$POSTGRES_PASSWORD
postgres_connect="--host=${POSTGRES_HOST} --user=serlo kratos"
psql $postgres_connect -c "DROP SCHEMA public CASCADE;"
psql $postgres_connect -c "CREATE SCHEMA public;"
psql $postgres_connect -c "GRANT ALL ON SCHEMA public TO serlo;"
psql $postgres_connect <kratos.sql

# delete all unnecessary files
rm -f $(ls /tmp/dump*.zip | grep -v $newest_dump)
rm /tmp/*.sql /tmp/user.csv
