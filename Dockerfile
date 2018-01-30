FROM traefik:1.5.0-rc5-alpine

ADD ./env_secrets_expand.sh /usr/local/bin/env_secrets_expand.sh

# install s3cmd, cron and supervisord

ENV S3CMD_VERSION 1.6.1
ENV SUPERVISOR_VERSION=3.3.1

RUN apk update && \
    apk add --no-cache py-pip py-setuptools ca-certificates openssl dcron && \
    update-ca-certificates && \
    pip install python-magic && \
    pip install supervisor==$SUPERVISOR_VERSION && \
    cd /tmp && \
    wget https://github.com/s3tools/s3cmd/releases/download/v${S3CMD_VERSION}/s3cmd-${S3CMD_VERSION}.tar.gz && \
    tar xzf s3cmd-${S3CMD_VERSION}.tar.gz && \
    cd s3cmd-${S3CMD_VERSION} && \
    python setup.py install && \
    rm -rf /var/cache/apk/* /tmp/s3cmd-${S3CMD_VERSION} /tmp/s3cmd-${S3CMD_VERSION}.tar.gz && \
    mkdir -p /var/log/supervisord && \
    rm /entrypoint.sh && \
    mkdir -p /etc/cron.d

ADD ./supervisord.conf /etc/supervisord.conf

ADD ./entrypoint.sh /entrypoint.sh
ADD ./.s3cfg /root/.s3cfg
ADD ./backup.sh /usr/local/bin/backup.sh

ADD ./traefik.toml /etc/traefik/
