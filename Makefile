.DEFAULT_GOAL := build

build:
	@echo writing meta
	@v run util/write-meta.v
	@echo compiling
	@v -prod .
