FROM ubuntu:18.04 as builder

ENV demo_artifacts_version "1.6.0"
ENV repo_url "https://nexus.onap.org/content/repositories/releases/org/onap/demo/vnf/"

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
  wget=1.19.4-1ubuntu2.2 \
  ca-certificates=20211016~18.04.1 \
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
  openjdk-8-jre=8u342-b07-0ubuntu1~18.04 \
  iproute2=4.15.0-2ubuntu1.3 \
  libcurl4-gnutls-dev=7.58.0-2ubuntu3.19 \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /opt/pg_streams

ENTRYPOINT ["/bin/bash"]
CMD ["/opt/init.sh"]
