ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION}
LABEL maintainer sndsgd

ARG NODE_VERSION
ARG POSTCSS_VERSION

RUN \
  apk add --update --no-cache \
    nodejs=${NODE_VERSION} \
    nodejs-npm=${NODE_VERSION} \
  && npm install -g \
    postcss@${POSTCSS_VERSION} \
    postcss-cli \
    autoprefixer \
    cssnano

ENTRYPOINT ["/usr/bin/postcss"]
