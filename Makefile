CWD := $(shell pwd)

BUILD_ARGS ?= --quiet

NODE_VERSION ?= 12.18.4-r0
POSTCSS_VERSION ?= 8.1.4

IMAGE_NAME ?= sndsgd/postcss
IMAGE := $(IMAGE_NAME):$(POSTCSS_VERSION)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[33m%s\033[0m~%s\n", $$1, $$2}' \
	| column -s "~" -t

.PHONY: image
image: ## Build the docker image
	@echo "building image..."
	@docker build \
	  $(BUILD_ARGS) \
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
	docker run --rm $(IMAGE) --help

.PHONY: run-version
run-version: ## Run `postcss --version`
run-version: image
	docker run --rm $(IMAGE) --version

.DEFAULT_GOAL := help
