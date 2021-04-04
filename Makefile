.DEFAULT_GOAL := build

VC = v
VFLAGS =

ARTIFACT = vrelease


clean:
	@rm -rf $(ARTIFACT)

build: clean
	@printf "\nVRELEASE BUILD\n"
	@printf "\n>>> parameters\n"
	@printf "* VC: %s (%s)\n" "$(VC)" "$(shell which $(VC))"
	@printf "* VFLAGS: %s\n" "$(strip $(VFLAGS))"
	@printf "* PATH:\n" "$(PATH)"
	@echo "$(PATH)" | tr ':' '\n' | xargs -n 1 printf "   - %s\n"
	@printf "\n"
	@printf "\n>>> write-meta\n"
	$(VC) run scripts/write-meta.v
	@printf "\n>>> compiling\n"
	$(VC) $(VFLAGS) .
	@printf "\n* binary size: "
	@du -h $(ARTIFACT) | cut -f -1

build-release: VFLAGS += -prod
build-release: build
build-release:
	@printf "\n\n>>> striping binary\n"
	strip -SXNx $(ARTIFACT)
	@printf "\n* new binary size: "
	@du -h $(ARTIFACT) | cut -f -1
