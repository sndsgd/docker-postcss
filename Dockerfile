FROM alpine:3.12
LABEL maintainer sndsgd

ARG NODE_VERSION
ARG POSTCSS_VERSION

RUN apk add --update --no-cache nodejs=${NODE_VERSION} nodejs-npm \
    && npm install -g \
        postcss@${POSTCSS_VERSION} \
        postcss-cli \
        autoprefixer \
        cssnano

ENTRYPOINT ["postcss"]
