FROM alpine:3.12
LABEL maintainer sndsgd

ARG NODE_VERSION=12.17.0-r0
ARG POSTCSS_VERSION=7.0.32

RUN apk add --update --no-cache nodejs=${NODE_VERSION} nodejs-npm \
    && npm install -g \
        postcss@${POSTCSS_VERSION} \
        postcss-cli \
        autoprefixer \
        cssnano

ENTRYPOINT ["postcss"]
