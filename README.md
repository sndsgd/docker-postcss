# sndsgd/docker-postcss

A docker image with [postcss](https://postcss.org/) and a few plugins that I use.


### Build

If you want to build the image locally, you can follow these steps:

1. Checkout this repo
1. Run `make build-image`


### Usage

_dev build_

    docker run --rm -v $(pwd):$(pwd) -w $(pwd) sndsgd/postcss \
    --use autoprefixer --output output.css input.css

_production build_

    docker run --rm -v $(pwd):$(pwd) -w $(pwd) sndsgd/postcss \
    --no-map --use autoprefixer --use cssnano --output output.css input.css
