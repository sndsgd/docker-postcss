CWD := $(shell pwd)

NODE_VERSION ?= 12.21.0-r0
POSTCSS_VERSION ?=

IMAGE_NAME ?= sndsgd/postcss

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[33m%s\033[0m~%s\n", $$1, $$2}' \
	| column -s "~" -t

VERSION_URL ?= https://www.npmjs.com/package/postcss
VERSION_PATTERN ?= '(?<="latest":")[^"]+(?=")'
.PHONY: ensure-version
ensure-version:
ifeq ($(POSTCSS_VERSION),)
	$(info fetching latest version...)
	@$(eval POSTCSS_VERSION = $(shell curl -s $(VERSION_URL) | grep -Po $(VERSION_PATTERN) | head -1))
endif
	@$(eval IMAGE := $(IMAGE_NAME):$(POSTCSS_VERSION))

IMAGE_ARGS ?= --quiet
.PHONY: image
image: ## Build the docker image
image: ensure-version
	$(info building image for postcss v$(POSTCSS_VERSION)...)
	@docker build \
	  $(IMAGE_ARGS) \
		--build-arg NODE_VERSION=$(NODE_VERSION) \
		--build-arg POSTCSS_VERSION=$(POSTCSS_VERSION) \
		--tag $(IMAGE_NAME):latest \
		--tag $(IMAGE) \
		$(CWD)

.PHONY: test
test: ## Test the docker image
test: image
	@make --no-print-directory execute-test \
		POSTCSS_VERSION=$(POSTCSS_VERSION) \
		TEST_ARGS="--no-map --use autoprefixer" \
		TEST_NAME=one
	@make --no-print-directory execute-test \
		POSTCSS_VERSION=$(POSTCSS_VERSION) \
		TEST_ARGS="--no-map --use autoprefixer --use cssnano" \
		TEST_NAME=two

TEST_ARGS ?=
TEST_INPUT ?= test.css
TEST_NAME ?=
.PHONY: execute-test
execute-test: ensure-version
	$(info testing $(TEST_NAME)...)
	@docker run --rm -t \
		-v $(CWD):$(CWD) \
		-w $(CWD) $(IMAGE) \
		$(TEST_ARGS) --output - tests/$(TEST_INPUT) \
		| diff --ignore-trailing-space tests/expect.$(TEST_NAME).css -

.PHONY: push
push: ## Push the docker image
push: test
	docker push $(IMAGE)
	docker push $(IMAGE_NAME):latest

IMAGE_CHECK_URL = https://index.docker.io/v1/repositories/$(IMAGE_NAME)/tags/$(POSTCSS_VERSION)
.PHONY: push-cron
push-cron: ## Build and push an image if the version does not exist
	curl --silent -f -lSL $(IMAGE_CHECK_URL) > /dev/null \
	  || make --no-print-directory push IMAGE_ARGS=--no-cache

.PHONY: run-help
run-help: ## Run `postcss --help`
run-help: image
	@docker run --rm $(IMAGE) --help

.DEFAULT_GOAL := help
