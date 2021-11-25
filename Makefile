.DEFAULT_GOAL := build

VC = v
VFLAGS = -W -showcc -show-c-output -show-timings

SRC_DIR = src
ARTIFACT = vrelease
HERE = $(shell pwd)


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
	cd .scripts && $(VC) run write-meta.v
	@printf "\n>>> compile\n"
	cd $(HERE) && $(VC) $(VFLAGS) $(SRC_DIR) -o $(ARTIFACT)
	@printf "\n* binary size: "
	@du -h $(ARTIFACT) | cut -f -1
	@printf "\nDONE\n"

debug: VFLAGS += -g -cstrict
debug: build

trace: VFLAGS += -d trace_http_request -d trace_http_response
trace: debug

.PHONY: release
release: VFLAGS += -prod -compress -nocolor
release: build

.PHONY: static
static: VFLAGS += -cflags '--static'
static: release
