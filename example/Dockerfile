FROM debian:bookworm

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --yes \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends \
        git ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/wsuzume/devel-entrypoint.git \
    && cd devel-entrypoint \
    && /bin/bash install.sh
