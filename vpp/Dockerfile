FROM ubuntu:16.04
MAINTAINER Victor Morales <electrocucaracha@gmail.com>

RUN apt-get update && apt-get install -y -qq apt-transport-https \
 && echo "deb [trusted=yes] https://nexus.fd.io/content/repositories/fd.io.stable.1609.ubuntu.xenial.main/ ./" | tee -a /etc/apt/sources.list.d/99fd.io.list \
 && apt-get update \
 && apt-get install -y -qq vpp vpp-lib vpp-plugins 

COPY 80-vpp.conf /etc/sysctl.d/80-vpp.conf

CMD ["/usr/bin/vpp", "-c", "/etc/vpp/startup.conf"]
