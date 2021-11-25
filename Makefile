.DEFAULT_GOAL := build

N = nimble
NFLAGS = --verbose -d:ssl

ARTIFACT = vrelease


clean:
	@rm -rf $(ARTIFACT)

build: clean
	$(N) build $(NFLAGS)

release: NFLAGS += -d:release
release: build
	@strip $(ARTIFACT)
	@upx --best --lzma $(ARTIFACT)
