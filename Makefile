program_name=unicornleap
image_folder=$(HOME)/.$(program_name)
build_folder=build
PREFIX ?= /usr/local
DESTDIR ?=

# Embed the default images in the binary's __TEXT segment (see LeapImage.swift).
embed_images = -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __unicorn_png -Xlinker images/unicorn.png \
	-Xlinker -sectcreate -Xlinker __TEXT -Xlinker __sparkle_png -Xlinker images/sparkle.png

swiftc = xcrun swiftc -swift-version 5 -O $(embed_images)

sources = $(wildcard UnicornLeap/*.swift)
binary = $(build_folder)/$(program_name)

.PHONY: all universal test clean images install

all: $(binary)

# Rebuilt when a source file or an embedded image changes, so `make install`
# never installs a stale binary.
$(binary): $(sources) images/unicorn.png images/sparkle.png
	mkdir -p $(build_folder)
	$(swiftc) -o $@ $(sources)

# Universal (x86_64 + arm64) binary, as shipped in GitHub releases.
# arm64 macOS starts at 11.0, so that slice can't target 10.15.
universal:
	mkdir -p $(build_folder)
	$(swiftc) -target x86_64-apple-macos10.15 -o $(build_folder)/$(program_name)-x86_64 UnicornLeap/*.swift
	$(swiftc) -target arm64-apple-macos11 -o $(build_folder)/$(program_name)-arm64 UnicornLeap/*.swift
	lipo -create -output $(build_folder)/$(program_name) \
		$(build_folder)/$(program_name)-x86_64 $(build_folder)/$(program_name)-arm64
	rm $(build_folder)/$(program_name)-x86_64 $(build_folder)/$(program_name)-arm64

test:
	swift test

images:
	mkdir -p $(image_folder)
	cp images/*.png $(image_folder)

install: $(binary)
	install -d $(DESTDIR)$(PREFIX)/bin $(DESTDIR)$(PREFIX)/share/man/man1
	install -m 755 $(build_folder)/$(program_name) $(DESTDIR)$(PREFIX)/bin/$(program_name)
	install -m 644 $(program_name).1 $(DESTDIR)$(PREFIX)/share/man/man1/

clean:
	rm -rf $(build_folder) .build
