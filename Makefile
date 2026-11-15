program_name=unicornleap
image_folder=$(HOME)/.$(program_name)
build_folder=build
PREFIX ?= /usr/local

# Embed the default images in the binary's __TEXT segment (see LeapImage.swift).
embed_images = -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __unicorn_png -Xlinker images/unicorn.png \
	-Xlinker -sectcreate -Xlinker __TEXT -Xlinker __sparkle_png -Xlinker images/sparkle.png

swiftc = xcrun swiftc -swift-version 5 -O $(embed_images)

.PHONY: all universal xcode test clean images install

all:
	mkdir -p $(build_folder)
	$(swiftc) -o $(build_folder)/$(program_name) UnicornLeap/*.swift

# Universal (x86_64 + arm64) binary, as shipped in GitHub releases.
# arm64 macOS starts at 11.0, so that slice can't target 10.11.
universal:
	mkdir -p $(build_folder)
	$(swiftc) -target x86_64-apple-macos10.11 -o $(build_folder)/$(program_name)-x86_64 UnicornLeap/*.swift
	$(swiftc) -target arm64-apple-macos11 -o $(build_folder)/$(program_name)-arm64 UnicornLeap/*.swift
	lipo -create -output $(build_folder)/$(program_name) \
		$(build_folder)/$(program_name)-x86_64 $(build_folder)/$(program_name)-arm64
	rm $(build_folder)/$(program_name)-x86_64 $(build_folder)/$(program_name)-arm64

xcode:
	xcodebuild CONFIGURATION_BUILD_DIR=$(build_folder) PRODUCT_NAME=$(program_name)

test:
	xcodebuild -workspace unicornleap.xcodeproj/project.xcworkspace/ -scheme UnicornLeapTests test

images:
	mkdir -p $(image_folder)
	cp images/*.png $(image_folder)

install:
	cp $(build_folder)/$(program_name) $(PREFIX)/bin/$(program_name)
	cp $(program_name).1 $(PREFIX)/share/man/man1/

clean:
	rm -rf $(build_folder)
