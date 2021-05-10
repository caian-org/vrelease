FROM thevlang/vlang:alpine-dev AS base
MAINTAINER Caian R. Ertl <hi@caian.org>
RUN apk update && \
    apk add --no-cache git upx

FROM base AS build
WORKDIR /vr
COPY .git     /vr/.git
COPY src      /vr/src
COPY scripts  /vr/scripts
COPY Makefile /vr
COPY v.mod    /vr
RUN make static

FROM alpine:3.13 AS plat
RUN apk update && \
    apk add --no-cache git curl

FROM plat AS run
COPY --from=build /vr/vrelease /vrelease
ENTRYPOINT ["/vrelease"]
