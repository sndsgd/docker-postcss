CWD := $(shell pwd)

NODE_VERSION ?= 12.17.0-r0
POSTCSS_VERSION ?= 7.0.32

IMAGE_NAME ?= sndsgd/postcss
IMAGE := $(IMAGE_NAME):$(POSTCSS_VERSION)

.PHONY: build-image
build-image:
	docker build \
		--build-arg NODE_VERSION=$(NODE_VERSION) \
		--build-arg POSTCSS_VERSION=$(POSTCSS_VERSION) \
		--tag $(IMAGE_NAME):latest \
		--tag $(IMAGE) \
		$(CWD)

.PHONY: build
build: build-image
	docker push $(IMAGE)
	docker push $(IMAGE_NAME):latest

.PHONY: help
help: build-image
	docker run --rm $(IMAGE) --help
