FROM ubuntu:18.04

ARG VERSION=21.10.1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update && apt-get install -y -qq --no-install-recommends \
  curl=7.58.0-2ubuntu3.20 \
  ca-certificates=20211016~18.04.1 \
  gnupg2=2.2.4-1ubuntu1.6 \
  && rm -rf /var/lib/apt/lists/*

 RUN echo "deb [trusted=yes] https://packagecloud.io/fdio/release/ubuntu bionic main" | tee /etc/apt/sources.list.d/99fd.io.list \
  && curl -L https://packagecloud.io/fdio/release/gpgkey | apt-key add - \
  && mkdir -p /var/log/vpp/ \
  && apt-get update && apt-get install -y -qq --no-install-recommends \
  vpp-plugin-core=$VERSION-release \
  && rm -rf /var/lib/apt/lists/*
