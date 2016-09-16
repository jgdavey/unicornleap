program_name=unicornleap
image_folder=$(HOME)/.$(program_name)
build_folder=build
PREFIX ?= /usr/local

.PHONY: all clean images

all:
	xcodebuild CONFIGURATION_BUILD_DIR=$(build_folder) PRODUCT_NAME=$(program_name)

test:
	xcodebuild -workspace unicornleap.xcodeproj/project.xcworkspace/ -scheme UnicornLeapTests test

images:
	mkdir -p $(image_folder)
	cp images/*.png $(image_folder)

install: images
	cp $(build_folder)/$(program_name) $(PREFIX)/bin/$(program_name)
	cp $(program_name).1 $(PREFIX)/share/man/man1/

clean:
	rm -rf $(build_folder)
