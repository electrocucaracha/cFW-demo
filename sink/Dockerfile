FROM ubuntu:16.04
MAINTAINER Victor Morales <electrocucaracha@gmail.com>

ARG HTTP_PROXY=${HTTP_PROXY}
ARG HTTPS_PROXY=${HTTPS_PROXY}

ENV http_proxy $HTTP_PROXY
ENV https_proxy $HTTPS_PROXY

ENV protected_net_cidr "192.168.20.0/24"
ENV fw_ipaddr "192.168.10.100"
ENV sink_ipaddr "192.168.20.250"
ENV demo_artifacts_version "1.3.0"
ENV protected_net_gw "192.168.20.100"
ENV unprotected_net "192.168.10.0/24"

RUN apt-get update && apt-get install -y -qq wget darkstat net-tools \
 && sed -i "s/START_DARKSTAT=.*/START_DARKSTAT=yes/g;s/INTERFACE=.*/INTERFACE=\"-i eth1\"/g" /etc/darkstat/init.cfg 

WORKDIR /opt
EXPOSE 667

RUN wget "https://git.onap.org/demo/plain/vnfs/vFW/scripts/v_sink_init.sh" \
 && chmod +x v_sink_init.sh 

RUN mkdir -p /opt/config/ \
 && echo $protected_net_cidr > /opt/config/protected_net_cidr.txt \
 && echo $fw_ipaddr > /opt/config/fw_ipaddr.txt \
 && echo $sink_ipaddr > /opt/config/sink_ipaddr.txt \
 && echo $demo_artifacts_version > /opt/config/demo_artifacts_version.txt \
 && echo $protected_net_gw > /opt/config/protected_net_gw.txt \
 && echo $unprotected_net > /opt/config/unprotected_net.txt

CMD ["./v_sink_init.sh"]
