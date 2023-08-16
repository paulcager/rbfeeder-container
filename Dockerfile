# bullseye is the latest supported by rbfeeder.
# Derived from https://apt.rb24.com/inst_rbfeeder.sh

FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y gnupg2 lsb-release dirmngr

RUN echo 'deb https://apt.rb24.com/ bullseye main' > /etc/apt/sources.list.d/rb24.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 1D043681 && \
    apt-get update && \
    apt-get install -y rbfeeder

CMD ["/usr/bin/rbfeeder"]
