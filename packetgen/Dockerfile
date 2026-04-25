FROM ubuntu:18.04 as builder

ENV demo_artifacts_version "1.6.0"
ENV repo_url "https://nexus.onap.org/content/repositories/releases/org/onap/demo/vnf/"

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
  wget \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
EXPOSE 8183

RUN wget -q "${repo_url}/sample-distribution/${demo_artifacts_version}/sample-distribution-${demo_artifacts_version}-hc.tar.gz" \
  && tar -zmxf sample-distribution-${demo_artifacts_version}-hc.tar.gz \
  && rm sample-distribution-${demo_artifacts_version}-hc.tar.gz \
  && mv sample-distribution-${demo_artifacts_version} honeycomb \
  && sed -i 's/"restconf-binding-address": .*/"restconf-binding-address": "0.0.0.0",/g' /opt/honeycomb/config/restconf.json

FROM vpp:21.10.1

COPY --from=builder /opt/honeycomb /opt/honeycomb
COPY init.sh /opt/init.sh

ENV PROTECTED_NET_CIDR "192.168.20.0/24"
ENV FW_IPADDR "192.168.10.100"
ENV SINK_IPADDR "192.168.20.250"

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
  openjdk-8-jre \
  iproute2 \
  libcurl4-gnutls-dev \
  bsdmainutils \
  bridge-utils \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /opt/pg_streams

ENTRYPOINT ["/bin/bash"]
CMD ["/opt/init.sh"]
