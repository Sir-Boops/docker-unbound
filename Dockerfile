FROM alpine:3.8

ENV UNB_VER="1.8.0"

RUN addgroup unbound && \
        adduser -D -h /opt -G unbound unbound && \
        echo "unbound:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -m sha256`" | chpasswd

RUN apk -U add --virtual deps \
        make gcc g++ libressl-dev \
        expat-dev libevent-dev && \
    apk add libevent && \
    cd ~ && \
    wget https://unbound.net/downloads/unbound-$UNB_VER.tar.gz && \
    tar xf unbound-$UNB_VER.tar.gz && \
    cd ~/unbound-$UNB_VER && \
    ./configure --prefix=/opt/unbound \
        --with-libevent && \
    make -j$(nproc) && \
    make install && \
    cd /opt/unbound/etc/unbound/ && \
    rm unbound.conf && \
    rm -rf ~/* && \
    apk del --purge deps

COPY unbound.conf /opt/unbound/etc/unbound/
COPY root.key /opt/unbound/etc/unbound/
COPY root.db /opt/unbound/etc/unbound/

RUN chown unbound:unbound -R /opt/*

CMD /opt/unbound/sbin/unbound -dv
