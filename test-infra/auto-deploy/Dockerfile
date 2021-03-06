# Docker image for nightly deployment cronjob.

FROM ubuntu:xenial
MAINTAINER Gabriel Wen

# Never prompt the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# gcc & python-dev are needed so we can install crcmod for gsutil
# also includes installations for Python3
RUN set -ex \
    && apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
    build-essential \
    curl \
    wget \
    git \
    jq \
    zip \
    unzip \
    gcc \
    ssh \
    python-dev \
    python-setuptools \
    python-pip \
    python3-dev \
    python3-setuptools \
    python3-pip \
    && python -V \
    && python3 -V \
    && apt-get clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
    /usr/share/man \
    /usr/share/doc \
    /usr/share/doc-base

# Install go
RUN cd /tmp && \
    wget -O /tmp/go.tar.gz https://redirector.gvt1.com/edgedl/go/go1.9.2.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz

# Install gcloud
ENV PATH=/usr/local/go/bin:/google-cloud-sdk/bin:/workspace:${PATH} \
    CLOUDSDK_CORE_DISABLE_PROMPTS=1

RUN wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz && \
    tar xzf google-cloud-sdk.tar.gz -C / && \
    rm google-cloud-sdk.tar.gz && \
    /google-cloud-sdk/install.sh \
    --disable-installation-options \
    --bash-completion=false \
    --path-update=false \
    --usage-reporting=false && \
    gcloud components install alpha beta

# Install yarn
RUN curl -sS http://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends yarn

# Install glide
RUN cd /tmp && \
    wget -O glide-v0.13.0-linux-amd64.tar.gz \
    https://github.com/Masterminds/glide/releases/download/v0.13.0/glide-v0.13.0-linux-amd64.tar.gz && \
    tar -xvf glide-v0.13.0-linux-amd64.tar.gz && \
    mv ./linux-amd64/glide /usr/local/bin/

# Install ksonnet. We install multiple versions of ks to support different versions
# of ksonnet applications. Newer versions of ksonnet are backwards compatible but
# that can require upgrading the app which isn't something we want to be forced to.
# (see https://github.com/kubeflow/testing/issues/220).
RUN cd /tmp && \
    wget -O ks.tar.gz \
    https://github.com/ksonnet/ksonnet/releases/download/v0.11.0/ks_0.11.0_linux_amd64.tar.gz && \
    tar -xvf ks.tar.gz && \
    mv ks_0.11.0_linux_amd64/ks /usr/local/bin && \
    chmod a+x /usr/local/bin/ks

RUN cd /tmp && \
    wget -O ks-12.tar.gz \
    https://github.com/ksonnet/ksonnet/releases/download/v0.12.0/ks_0.12.0_linux_amd64.tar.gz && \
    tar -xvf ks-12.tar.gz && \
    mv ks_0.12.0_linux_amd64/ks /usr/local/bin/ks-12 && \
    chmod a+x /usr/local/bin/ks-12

RUN cd /tmp && \
    wget -O ks-13.tar.gz \
    https://github.com/ksonnet/ksonnet/releases/download/v0.13.1/ks_0.13.1_linux_amd64.tar.gz && \
    tar -xvf ks-13.tar.gz && \
    mv ks_0.13.1_linux_amd64/ks /usr/local/bin/ks-13 && \
    chmod a+x /usr/local/bin/ks-13

RUN cd /tmp && \
    wget https://github.com/google/jsonnet/archive/v0.11.2.tar.gz && \
    tar -xvf v0.11.2.tar.gz && \
    cd jsonnet-0.11.2 && \
    make && \
    mv jsonnet /usr/local/bin && \
    rm -rf /tmp/v0.11.2.tar.gz && \
    rm -rf /tmp/jsonnet-0.11.2

# Install various python libraries for both Python 2 and 3 (for now)
# Don't upgrade pip for now because it seems to be broken
# https://github.com/pypa/pip/issues/5240
COPY ./Pipfile ./Pipfile.lock /tmp/

RUN cd /tmp/ && \
    pip2 install -U wheel filelock && \
    pip2 install pipenv && \
    pipenv install --system --two && \
    pip3 install -U wheel filelock

RUN pip3 install pipenv==2018.10.9
RUN cd /tmp/ && pipenv install --system --three

# Install docker.
RUN curl  https://get.docker.com/ | sh

# Install kubectl
RUN  curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/amd64/kubectl && \
    mv kubectl /usr/local/bin && \
    chmod a+x /usr/local/bin/kubectl

# Work around for https://github.com/ksonnet/ksonnet/issues/298
ENV USER root

# Purpose of init.sh is to have a script as kickstarter. This script is used to pull fresh copy from
# Github and run with them.
COPY checkout_lib /usr/local/bin/py/checkout_lib
COPY init.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/init.sh
COPY checkout-snapshot.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/checkout-snapshot.sh
