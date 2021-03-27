.DEFAULT_GOAL := build

VC = v
VFLAGS =

build:
	@echo writing meta
	@$(VC) run util/write-meta.v
	@echo compiling
	@$(VC) $(VFLAGS) .

build-release: VFLAGS += -prod
build-release: build
