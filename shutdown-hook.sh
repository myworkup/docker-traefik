#!/usr/bin/env bash
set -e

. /usr/local/bin/env_secrets_expand.sh

# SIGTERM-handler
term_handler() {

    S3_BUCKET="${S3_BUCKET-no}"
    S3_PATH="${S3_PATH-no}"
    S3_ACCESS_KEY="${S3_ACCESS_KEY-no}"
    S3_SECRET_KEY="${S3_SECRET_KEY-no}"
    S3_REGION="${S3_REGION-no}"

    # determine whether we should register backup jobs

    [ "${S3_BUCKET}" != 'no' ] && \
    [ "${S3_PATH}" != 'no' ] && \
    [ "${S3_ACCESS_KEY}" != 'no' ] && \
    [ "${S3_SECRET_KEY}" != 'no' ] && \
    [ "${S3_REGION}" != 'no' ]

    if [ "$?" -eq 0 ]; then
        echo 'Backup up acme json on shutdown'
        /usr/local/bin/backup.sh
    fi

  exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; term_handler' SIGTERM

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
