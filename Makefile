.DEFAULT_GOAL := build

ARTIFACT = vrelease

N = nimble
NFLAGS = --verbose -o:vrelease -d:ssl


clean:
	@rm -rf $(ARTIFACT)

build: clean
	$(N) build $(NFLAGS)

release: NFLAGS += -d:release
release: build
	@strip $(ARTIFACT)
	@upx --best --lzma $(ARTIFACT)
