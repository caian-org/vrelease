.DEFAULT_GOAL := build

VC = v
VFLAGS =

build:
	@printf "\nVRELEASE PRE-BUILD\n\n"
	@printf "* VC: %s (%s)\n" "$(VC)" "$(shell which $(VC))"
	@printf "* VFLAGS: %s\n" "$(strip $(VFLAGS))"
	@printf "* PATH:\n" "$(PATH)"
	@echo "$(PATH)" | tr ':' '\n' | xargs -n 1 printf "   - %s\n"
	@printf "\n"
	$(VC) run scripts/write-meta.v
	@printf ">>> compiling\n"
	$(VC) $(VFLAGS) .
	@printf "\nDONE\n"

build-release: VFLAGS += -prod
build-release: build
