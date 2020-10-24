SHELL := /bin/bash
CWD := $(shell pwd)

NODE_VERSION ?= 12.18.4-r0
POSTCSS_VERSION ?= 8.1.4

IMAGE_NAME ?= sndsgd/postcss
IMAGE := $(IMAGE_NAME):$(POSTCSS_VERSION)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[33m%s\033[0m~%s\n", $$1, $$2}' \
	| column -s "~" -t

IMAGE_ARGS ?= --quiet
.PHONY: image
image: ## Build the docker image
	@echo "building image..."
	@docker build \
	  $(IMAGE_ARGS) \
		--build-arg NODE_VERSION=$(NODE_VERSION) \
		--build-arg POSTCSS_VERSION=$(POSTCSS_VERSION) \
		--tag $(IMAGE_NAME):latest \
		--tag $(IMAGE) \
		$(CWD)

.PHONY: push
push: ## Push the docker image
push: image
	docker push $(IMAGE)
	docker push $(IMAGE_NAME):latest

.PHONY: run-help
run-help: ## Run `postcss --help`
run-help: image
	@docker run --rm $(IMAGE) --help

VERSION_URL ?= https://www.npmjs.com/package/postcss
VERSION_PATTERN ?= '(?<="latest":")[^"]+(?=")'
.PHONY: fetch-version
fetch-version:
	@$(eval NEW_POSTCSS_VERSION = $(shell curl -s $(VERSION_URL) | grep -Po $(VERSION_PATTERN)))
	@echo -e "current ~$(POSTCSS_VERSION)\nlatest~$(NEW_POSTCSS_VERSION)" \
		| column -s "~" -t
	@sed -i 's/^POSTCSS_VERSION ?=.*$$/POSTCSS_VERSION ?= $(NEW_POSTCSS_VERSION)/' ./Makefile
	#


.DEFAULT_GOAL := help
