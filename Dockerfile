FROM golang:alpine3.10

RUN apk add perl apk add bash
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community \
    alpine-sdk gflags godep
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    snappy rocksdb

EXPOSE 6380 11181

#RUN apk add lua5.1 lua5.1-dev # --update-cache --repository http://nl.alpinelinux.org/alpine/edge/testing

RUN mkdir -p /usr/local/rocksdb/lib && \
    mkdir /usr/local/rocksdb/include && \
    cp -r /usr/lib/librocksdb.so.* /usr/local/rocksdb/lib

# Compile and build LedisDB
RUN mkdir -p $GOPATH/src/github.com/siddontang && \
    cd $GOPATH/src/github.com/siddontang && \
    git clone https://github.com/kopetgroup/ledisdb.git && cd ledisdb && \
    cat build_config.mk; make; \
    mv ./bin/ledis* $GOPATH/bin/

RUN apk del build-base linux-headers git cmake bash

WORKDIR /home

COPY ./ledisdb.conf /etc/ledisdb.conf
CMD $GOPATH/bin/ledis-server -config=/etc/ledisdb.conf

