.PHONY: build
build:
	rustup target list --installed | grep wasm32-unknown-unknown \
		|| echo 'missing wasm32-unknown-unknown target, install with `rustup target add wasm32-unknown-unknown`'
	cargo build --target=wasm32-unknown-unknown --release

.PHONY: fmt
fmt:
	cargo fmt --all -- --check

.PHONY: lint
lint:
	cargo clippy -- -D warnings

.PHONY: test
test: fmt lint
	cargo test

.PHONY: clean
clean:
	cargo clean
