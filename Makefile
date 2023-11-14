# Note about the tearDown hack: this is based on https://stackoverflow.com/questions/28597794/how-can-i-clean-up-after-an-error-in-a-makefile
export SHELL:=/bin/bash
export SHELLOPTS:=$(if $(SHELLOPTS),$(SHELLOPTS):)pipefail:errexit
TMPDIR:=$(shell mktemp -d --dry-run)

.ONESHELL:

.PHONY: fmt
fmt:
	@echo Run fmt checks against rendered project
	CARGO_GENERATE_VALUE_PROJECT_NAME=demo \
	CARGO_GENERATE_VALUE_REGISTRY=ghcr.io \
	CARGO_GENERATE_VALUE_REGISTRY_MODULE_PATH_PREFIX='kubewarden/policies' \
	CARGO_GENERATE_TEST_CMD='cargo fmt' \
	cargo generate --test --all -- --check

.PHONY: lint
lint:
	@echo Run linters against rendered project
	CARGO_GENERATE_VALUE_PROJECT_NAME=demo \
	CARGO_GENERATE_VALUE_REGISTRY=ghcr.io \
	CARGO_GENERATE_VALUE_REGISTRY_MODULE_PATH_PREFIX='kubewarden/policies' \
	CARGO_GENERATE_TEST_CMD='cargo clippy' \
	cargo generate --test -- -D warnings

.PHONY: test
test: fmt lint
	@echo Run unit tests against rendered project
	CARGO_GENERATE_VALUE_PROJECT_NAME=demo \
	CARGO_GENERATE_VALUE_REGISTRY=ghcr.io \
	CARGO_GENERATE_VALUE_REGISTRY_MODULE_PATH_PREFIX='kubewarden/policies' \
	cargo generate --test

e2e-tests:
	function tearDown {
		rm -rf $(TMPDIR)
	}
	trap tearDown EXIT
	# We cannot use cargo-generate --test for e2e-tests, since we need to access
	# the project directory to access the e2e tests and the annotated wasm module.
	CARGO_GENERATE_VALUE_PROJECT_NAME=demo \
	CARGO_GENERATE_VALUE_REGISTRY=ghcr.io \
	CARGO_GENERATE_VALUE_REGISTRY_MODULE_PATH_PREFIX='kubewarden/policies' \
	cargo generate --path . --destination $(TMPDIR)
	cd $(TMPDIR)/demo && make e2e-tests
