FROM ubuntu:18.04

COPY init.sh /opt/init.sh

ENV PROTECTED_NET_GW "192.168.20.100"
ENV UNPROTECTED_NET "192.168.10.0/24"

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
  iproute2=4.15.0-2ubuntu1.3 \
  darkstat=3.0.719-1build1 \
  && rm -rf /var/lib/apt/lists/*

EXPOSE 667

ENTRYPOINT ["/bin/bash"]
CMD ["/opt/init.sh"]
