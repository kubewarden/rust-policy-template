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
