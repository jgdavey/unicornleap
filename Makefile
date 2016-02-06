program_name=unicornleap
executable_name=$(program_name).bin
image_folder=$(HOME)/.$(program_name)
build_folder=build
PREFIX ?= /usr/local

.PHONY: all clean

all:
	xcodebuild CONFIGURATION_BUILD_DIR=$(build_folder) PRODUCT_NAME=$(executable_name)

install:
	mkdir -p $(image_folder)
	cp images/*.png $(image_folder)
	cp $(build_folder)/$(executable_name) $(PREFIX)/bin
	cp $(program_name).1 $(PREFIX)/share/man/man1/

clean:
	rm -rf build
