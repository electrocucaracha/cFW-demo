FROM electrocucaracha/vpp
MAINTAINER Victor Morales <electrocucaracha@gmail.com>

ENV repo_url "https://nexus.onap.org/content/repositories/staging/org/onap/demo/vnf"

ENV protected_net_cidr "192.168.20.0/24"
ENV fw_ipaddr "192.168.10.100"
ENV sink_ipaddr "192.168.20.250"
ENV demo_artifacts_version "1.6.0"

RUN apt-get install -y -qq wget openjdk-8-jre bridge-utils net-tools \
 bsdmainutils iproute2

WORKDIR /opt
EXPOSE 8183

RUN wget "https://git.onap.org/demo/plain/vnfs/vFW/scripts/v_packetgen_init.sh" \
 && wget "https://git.onap.org/demo/plain/vnfs/vFW/scripts/run_traffic_fw_demo.sh" \
 && chmod +x *.sh \
 && sed -i 's|start vpp|/usr/bin/vpp -c /etc/vpp/startup.conf|g;s|/opt/honeycomb/sample-distribution-\$VERSION/honeycomb|/opt/honeycomb/honeycomb|g' v_packetgen_init.sh 

RUN wget "${repo_url}/sample-distribution/${demo_artifacts_version}/sample-distribution-${demo_artifacts_version}-hc.tar.gz" \
 && tar -zmxf sample-distribution-${demo_artifacts_version}-hc.tar.gz \
 && rm sample-distribution-${demo_artifacts_version}-hc.tar.gz \
 && mv sample-distribution-${demo_artifacts_version} honeycomb \
 && sed -i 's/"restconf-binding-address": "127.0.0.1",/"restconf-binding-address": "0.0.0.0",/g' /opt/honeycomb/config/honeycomb.json

RUN wget "${repo_url}/vfw/vfw_pg_streams/${demo_artifacts_version}/vfw_pg_streams-${demo_artifacts_version}-demo.tar.gz" \
 && tar -zmxf vfw_pg_streams-${demo_artifacts_version}-demo.tar.gz \
 && rm vfw_pg_streams-${demo_artifacts_version}-demo.tar.gz \
 && mv vfw_pg_streams-${demo_artifacts_version} pg_streams

RUN mkdir -p /opt/config/ \
 && echo $protected_net_cidr > /opt/config/protected_net_cidr.txt \
 && echo $fw_ipaddr > /opt/config/fw_ipaddr.txt \
 && echo $sink_ipaddr > /opt/config/sink_ipaddr.txt \
 && echo $demo_artifacts_version > /opt/config/demo_artifacts_version.txt

CMD ["./v_packetgen_init.sh"]
