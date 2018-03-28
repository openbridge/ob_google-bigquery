FROM alpine:latest
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
RUN set -x \
    && apk add --no-cache --virtual .persistent-deps \
        rsync \
        bash \
        curl \
        dateutils \
        ca-certificates \
        libressl \
        libressl2.6-libcrypto \
        libressl2.6-libssl \
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
    && ./google-cloud-sdk/install.sh --path-update=true --bash-completion=true --rc-path=/.bashrc --additional-components app-engine-java app-engine-python kubectl alpha beta gcd-emulator pubsub-emulator cloud-datastore-emulator bq core gsutil gcloud app-engine-go bigtable \
    && ln -s /lib /lib64 \
    && rm -rf /tmp/* \
    && gcloud config set core/disable_usage_reporting true \
    && gcloud config set component_manager/disable_update_check true \
    && gcloud config set metrics/environment github_docker_image \
    && gcloud --version \
    && mkdir /.ssh \
    && rm -rf /var/cache/apk/* \
    && apk del .build-deps

COPY usr/bin/ /usr/bin/
COPY lifecycle.json /lifecycle.json
COPY sql/ /sql/
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /usr/bin/ /docker-entrypoint.sh

VOLUME ["/.config"]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [""]
