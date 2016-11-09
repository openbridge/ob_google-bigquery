FROM alpine:latest
MAINTAINER Thomas Spicer <thomas@openbridge.com>

ENV CLOUDSDK_VERSION=133.0.0
ENV CLOUDSDK_PYTHON_SITEPACKAGES=1
ENV PATH /google-cloud-sdk/bin:$PATH
ENV HOME /
ENV BUILD_DEPS \
        g++ \
        gcc \
        linux-headers \
        wget \
        build-base \
        openssl-dev \
        python-dev \
        libffi-dev \
        unzip \
        ca-certificates \
        py-pip \
        gnupg \
        musl

COPY query.sh /query.sh
COPY lifecycle.json /lifecycle.json
COPY sql/ga360master.sql /ga360master.sql
COPY export.sh /export.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN set -x \
    && apk add --no-cache --virtual .persistent-deps \
        rsync \
        bash \
        coreutils \
        python \
        openssh-client \
    && apk add --no-cache --virtual .build-deps \
        $BUILD_DEPS \
    && pip install --upgrade pip crcmod setuptools pyopenssl awscli cryptography \
    && mkdir -p /etc/gcloud \
    && wget --no-check-certificate --directory-prefix=/tmp/  https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUDSDK_VERSION}-linux-x86_64.tar.gz \
    && tar zxvf /tmp/google-cloud-sdk-${CLOUDSDK_VERSION}-linux-x86_64.tar.gz -C / \
    && /google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --disable-installation-options \
    && gcloud --quiet components update app preview alpha beta app-engine-python bq core gsutil gcloud \
    && rm -rf /tmp/* \
    && google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true \
    && sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' /google-cloud-sdk/lib/googlecloudsdk/core/config.json \
    && chmod +x /query.sh /export.sh /docker-entrypoint.sh \
    && apk del .build-deps

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [""]
