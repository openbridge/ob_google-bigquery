FROM alpine:edge
MAINTAINER Thomas Spicer <thomas@openbridge.com>

ENV CLOUDSDK_PYTHON_SITEPACKAGES=1
ENV PATH /google-cloud-sdk/bin:$PATH
ENV HOME /
ENV BUILD_DEPS \
        g++ \
        gcc \
        linux-headers \
        wget \
        build-base \
        libressl-dev \
        python2-dev \
        libffi-dev \
        unzip \
        ca-certificates \
        py2-pip \
        gnupg \
        musl-dev
COPY usr/bin/ /usr/bin/
COPY lifecycle.json /lifecycle.json
COPY sql/ /sql/
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN set -x \
    && apk add --no-cache --virtual .persistent-deps \
        rsync \
        bash \
        curl \
        ca-certificates \
        libressl \
        libressl2.5-libcrypto \
        libressl2.5-libssl \
        coreutils \
        openssh-client \
        python2 \
        py-openssl \
    && apk add --no-cache --virtual .build-deps \
        $BUILD_DEPS \
    && pip install --upgrade pip crcmod setuptools awscli cryptography \
    && mkdir -p /etc/gcloud \
    && wget --no-check-certificate https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip \
    && unzip google-cloud-sdk.zip \
    && rm google-cloud-sdk.zip \
    && ./google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --additional-components app-engine-java app-engine-python app kubectl alpha beta gcd-emulator pubsub-emulator cloud-datastore-emulator bq core gsutil gcloud app-engine-go bigtable \
    && rm -rf /tmp/* \
    && google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true \
    && sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' /google-cloud-sdk/lib/googlecloudsdk/core/config.json \
    && mkdir /.ssh \
    && chmod +x /usr/bin/bigquery-run /usr/bin/bigquery-export /usr/bin/bigquery-import /docker-entrypoint.sh \
    && rm -rf /var/cache/apk/* \
    && apk del .build-deps

RUN chmod +x /usr/bin/

VOLUME ["/.config"]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [""]
