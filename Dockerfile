FROM thevlang/vlang:alpine-dev AS base
LABEL maintainer="Caian Ertl <hi@caian.org>"

RUN apk update && \
    apk add build-base coreutils musl-dev libffi-dev upx && \
    apk del openssl-dev && \
    apk add libressl-dev

FROM base AS build
WORKDIR /vr
COPY .git     /vr/.git
COPY .scripts /vr/.scripts
COPY src      /vr/src
COPY Makefile /vr
COPY v.mod    /vr
RUN make static

FROM alpine:3.13 AS plat
RUN mkdir -p /wd
RUN apk update && \
    apk add --no-cache git curl

FROM plat AS run
WORKDIR /wd
COPY --from=build /vr/vrelease /usr/local/bin/vrelease
ENTRYPOINT ["vrelease"]
