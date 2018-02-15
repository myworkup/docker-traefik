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

    # optional parameters

    # weekly backup (on sundays, but not the first day of the month)

    echo "0 3 2-31 * 0 root supervisorctl start acme-backup" > /etc/cron.d/backup-weekly

    # try to restore previous backup

    URL="s3://${S3_BUCKET}/${S3_PATH}/acme.json"
    COUNT=$(s3cmd ls ${URL} | wc -l)

    if [[ ${COUNT} -gt 0 ]]; then

        echo 'Backup found, restoring'

        s3cmd get ${URL} /etc/traefik/acme.json
        chmod 600 /etc/traefik/acme.json

        echo 'Backup restored'

    fi

fi

dockerize --template /etc/traefik/traefik.toml.tmpl:/etc/traefik/traefik.toml \
            --template /root/.s3cfg.tmpl:/root/.s3cfg \
            supervisord --configuration /etc/supervisord.conf
