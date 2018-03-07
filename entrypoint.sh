#!/bin/sh -e

. /usr/local/bin/env_secrets_expand.sh

S3_BUCKET="${S3_BUCKET-no}"
S3_PATH="${S3_PATH-no}"
S3_ACCESS_KEY="${S3_ACCESS_KEY-no}"
S3_SECRET_KEY="${S3_SECRET_KEY-no}"
S3_ENCRYPTION_KEY="${S3_ENCRYPTION_KEY-no}"

# determine whether we should register backup jobs

[ "${S3_BUCKET}" != 'no' ] && \
[ "${S3_PATH}" != 'no' ] && \
[ "${S3_ACCESS_KEY}" != 'no' ] && \
[ "${S3_SECRET_KEY}" != 'no' ] &&
[ "${S3_ENCRYPTION_KEY}" != 'no' ]

if [ "$?" -eq 0 ]; then

    echo "Configuring backup"
    echo "0 3 2-31 * 0 root supervisorctl start acme-backup" > /etc/cron.d/backup-weekly

    echo "Sleeping for 30 seconds to allow for acme file to be restored"
    sleep 30

fi

dockerize --template /etc/traefik/traefik.toml.tmpl:/etc/traefik/traefik.toml \
            --template /root/.s3cfg.tmpl:/root/.s3cfg \
            supervisord --configuration /etc/supervisord.conf
