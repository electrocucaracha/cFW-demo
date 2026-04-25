FROM ubuntu:18.04 as builder

ENV demo_artifacts_version "1.6.0"
ENV repo_url "https://nexus.onap.org/content/repositories/releases/org/onap/demo/vnf/"

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
  wget \
  ca-certificates \
  make \
  gcc \
  libc6-dev \
  libcurl4-gnutls-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN wget -q "${repo_url}/sample-distribution/${demo_artifacts_version}/sample-distribution-${demo_artifacts_version}-hc.tar.gz" \
  && tar -zmxf sample-distribution-${demo_artifacts_version}-hc.tar.gz \
  && rm sample-distribution-${demo_artifacts_version}-hc.tar.gz \
  && mv sample-distribution-${demo_artifacts_version} honeycomb \
  && sed -i 's/"restconf-binding-address": .*/"restconf-binding-address": "0.0.0.0",/g' /opt/honeycomb/config/restconf.json

RUN wget -q "${repo_url}/ves5/ves/${demo_artifacts_version}/ves-${demo_artifacts_version}-demo.tar.gz" \
 && tar -zmxf ves-${demo_artifacts_version}-demo.tar.gz \
 && rm ves-${demo_artifacts_version}-demo.tar.gz \
 && mv ves-${demo_artifacts_version} VES

RUN wget -q "${repo_url}/ves5/ves_vfw_reporting/${demo_artifacts_version}/ves_vfw_reporting-${demo_artifacts_version}-demo.tar.gz" \
 && tar -zmxf ves_vfw_reporting-${demo_artifacts_version}-demo.tar.gz \
 && rm ves_vfw_reporting-${demo_artifacts_version}-demo.tar.gz \
 && mv ves_vfw_reporting-${demo_artifacts_version} VES/evel/evel-library/code/VESreporting \
 && chmod +x VES/evel/evel-library/code/VESreporting/go-client.sh \
 && make -C /opt/VES/evel/evel-library/bldjobs/

FROM vpp:21.10.1

COPY --from=builder /opt/honeycomb /opt/honeycomb
COPY --from=builder /opt/VES/evel/evel-library/code/VESreporting /opt/VESreporting
COPY --from=builder /opt/VES/evel/evel-library/libs/x86_64/libevel.so /usr/lib/x86_64-linux-gnu/
COPY init.sh /opt/init.sh

ENV DCAE_COLLECTOR_IP ""
ENV DCAE_COLLECTOR_PORT ""

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
  openjdk-8-jre \
  iproute2 \
  libcurl4-gnutls-dev \
  bsdmainutils \
  bridge-utils \
  && rm -rf /var/lib/apt/lists/*

HEALTHCHECK NONE

ENTRYPOINT ["/bin/bash"]
CMD ["/opt/init.sh"]
