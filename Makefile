.DEFAULT_GOAL := build

ARTIFACT = vrelease

ifeq ($(OS),Windows_NT)
	ARTIFACT = vrelease.exe
endif

N = nimble
NFLAGS = --verbose -o:$(ARTIFACT) -d:ssl


clean:
	@rm -rf $(ARTIFACT)

build: clean
	$(N) build $(NFLAGS)

release: NFLAGS += -d:release
release: build
	@strip $(ARTIFACT)
	@upx --best --lzma $(ARTIFACT)
