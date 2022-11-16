check-deps:
	@cargo -V
	@forge -V

build:
	forge build
.PHONY: build

test:
	forge test
.PHONY: test

clean:
	forge clean
.PHONY: clean

