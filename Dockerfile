FROM alpine:3.5
MAINTAINER Thomas Spicer <thomas@openbridge.com>

ENV CLOUDSDK_VERSION=140.0.0
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
        coreutils \
        openssh-client \
        python2 \
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
    && wget --no-check-certificate --directory-prefix=/usr/bin https://raw.githubusercontent.com/openbridge/ob_hipchat/master/hipchat \
    && rm -f google-cloud-sdk-${CLOUDSDK_VERSION}-linux-x86_64.tar.gz \
    && mkdir /.ssh \
    && rm -rf /var/cache/apk/*\
    && apk del .build-deps

COPY usr/bin/ /usr/bin/
COPY lifecycle.json /lifecycle.json
COPY sql/ /sql/
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /usr/bin/bigquery-run /usr/bin/bigquery-export /docker-entrypoint.sh /usr/bin/hipchat

VOLUME ["/.config"]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [""]
