FROM ubuntu:16.04
MAINTAINER Victor Morales <electrocucaracha@gmail.com>

ARG HTTP_PROXY=${HTTP_PROXY}
ARG HTTPS_PROXY=${HTTPS_PROXY}

ENV http_proxy $HTTP_PROXY
ENV https_proxy $HTTPS_PROXY
ENV artifacts_version "1.3.0"
ENV repo_url "https://nexus.onap.org/content/repositories/staging/org/onap/demo/vnf"

RUN apt-get update \ 
 && apt-get install -y -qq software-properties-common \
 && add-apt-repository -y ppa:openjdk-r/ppa \
 && apt-get update \
 && apt-get install --allow-unauthenticated -y -qq make wget \
 openjdk-8-jdk gcc libcurl4-openssl-dev python-pip \
 bridge-utils apt-transport-https ca-certificates upstart \
 && yes | pip install jsonschema

WORKDIR /opt
EXPOSE 8183

RUN wget "https://git.onap.org/demo/plain/vnfs/vFW/scripts/v_packetgen_init.sh" \
 && wget "https://git.onap.org/demo/plain/vnfs/vFW/scripts/vpacketgen.sh" \
 && wget "https://git.onap.org/demo/plain/vnfs/vFW/scripts/run_traffic_fw_demo.sh" \
 && chmod +x *.sh \
 && sed -i 's/start vpp/systemctl start vpp/g;s|/opt/honeycomb/sample-distribution-\$VERSION/honeycomb|/opt/honeycomb/honeycomb|g' v_packetgen_init.sh \
 && mv vpacketgen.sh /etc/init.d/ \
 && update-rc.d vpacketgen.sh defaults

RUN wget "${repo_url}/sample-distribution/${artifacts_version}/sample-distribution-${artifacts_version}-hc.tar.gz" \
 && tar -zmxf sample-distribution-${artifacts_version}-hc.tar.gz \
 && mv sample-distribution-${artifacts_version} honeycomb \
 && sed -i 's/"restconf-binding-address": "127.0.0.1",/"restconf-binding-address": "0.0.0.0",/g' /opt/honeycomb/config/honeycomb.json

RUN wget "${repo_url}/vfw/vfw_pg_streams/${artifacts_version}/vfw_pg_streams-${artifacts_version}-demo.tar.gz" \
 && tar -zmxf vfw_pg_streams-${artifacts_version}-demo.tar.gz \
 && mv vfw_pg_streams-${artifacts_version} pg_streams

CMD ["systemctl", "star", "packetgen"]
