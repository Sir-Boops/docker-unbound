FROM alpine:3.10

ENV UNB_VER="1.9.6"

# Create Unbound User
RUN addgroup unbound && \
        adduser -D -S -h /opt -G unbound unbound

# Build Unbound
RUN apk -U add --virtual deps \
        make gcc g++ libressl-dev \
        expat-dev libevent-dev && \
    apk add libevent libressl2.7-libssl && \
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

# Copy needed configs and assets
COPY unbound.conf /opt/unbound/etc/unbound/
COPY root.key /opt/unbound/etc/unbound/
COPY root.db /opt/unbound/etc/unbound/

# Set ownership of files
RUN chown unbound:unbound -R /opt/*

# Run unbound in foreground
CMD /opt/unbound/sbin/unbound -dv
