.DEFAULT_GOAL := build

VC = v
VFLAGS = -W

SRC_DIR = src
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
	cd scripts && $(VC) run write-meta.v
	@printf "\n>>> compile\n"
	$(VC) $(VFLAGS) $(SRC_DIR) -o $(ARTIFACT)
	@printf "\n* binary size: "
	@du -h $(ARTIFACT) | cut -f -1
	@printf "\nDONE\n"

build-release: VFLAGS += -prod -show-timings -nocolor
build-release: build
