.PHONY: build
build:
	cargo build --target=wasm32-unknown-unknown --release

.PHONY: fmt
fmt:
	cargo fmt --all -- --check

.PHONY: test
test: fmt
	cargo test

.PHONY: clean
clean:
	cargo clean
