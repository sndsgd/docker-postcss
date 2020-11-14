CWD := $(shell pwd)

NODE_VERSION ?= 12.18.4-r0
POSTCSS_VERSION ?=

VERSION_URL ?= https://www.npmjs.com/package/postcss
VERSION_PATTERN ?= '(?<="latest":")[^"]+(?=")'
ifndef (POSTCSS_VERSION)
	POSTCSS_VERSION = $(shell curl -s $(VERSION_URL) | grep -Po $(VERSION_PATTERN))
endif

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
	@echo "building image for postcss v$(POSTCSS_VERSION)..."
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
		TEST_ARGS="--no-map --use autoprefixer" \
		TEST_NAME=one
	@make --no-print-directory execute-test \
		TEST_ARGS="--no-map --use autoprefixer --use cssnano" \
		TEST_NAME=two

TEST_ARGS ?=
TEST_INPUT ?= test.css
TEST_NAME ?=
.PHONY: execute-test
execute-test:
	@echo "testing $(TEST_NAME)..."
	@docker run --rm -t \
		-v $(CWD):$(CWD) \
		-w $(CWD) sndsgd/postcss \
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

VERSION_URL ?= https://www.npmjs.com/package/postcss
VERSION_PATTERN ?= '(?<="latest":")[^"]+(?=")'
.PHONY: update
update:
	@$(eval NEW_POSTCSS_VERSION = $(shell curl -s $(VERSION_URL) | grep -Po $(VERSION_PATTERN)))
	@echo "current ~$(POSTCSS_VERSION)\nlatest~$(NEW_POSTCSS_VERSION)" \
		| column -s "~" -t
	@sed -i 's/^POSTCSS_VERSION ?=.*$$/POSTCSS_VERSION ?= $(NEW_POSTCSS_VERSION)/' ./Makefile
	@git diff && git diff-index --quiet HEAD || make --no-print-directory push IMAGE_ARGS=--no-cache

.DEFAULT_GOAL := help
