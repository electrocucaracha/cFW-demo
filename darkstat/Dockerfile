FROM ubuntu:16.04
MAINTAINER Victor Morales <electrocucaracha@gmail.com>

RUN apt-get update && apt-get install -y -qq darkstat

EXPOSE 667

CMD ["/usr/sbin/darkstat", "-i", "eth1", "--no-daemon"]
