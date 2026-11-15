program_name=unicornleap
image_folder=$(HOME)/.$(program_name)
build_folder=build
PREFIX ?= /usr/local
DESTDIR ?=

# The shipped binary is built with SwiftPM (see Package.swift, which also
# embeds the default images in the binary's __TEXT segment).
swift_build = swift build -c release
x86_64_triple = x86_64-apple-macosx10.15
arm64_triple = arm64-apple-macosx11

sources = $(wildcard UnicornLeap/*.swift)
binary = $(build_folder)/$(program_name)

.PHONY: all universal test clean images install

all: $(binary)

# Rebuilt when a source file, the package or an embedded image changes, so
# `make install` never installs a stale binary.
$(binary): $(sources) Package.swift Package.resolved images/unicorn.png images/sparkle.png
	$(swift_build)
	mkdir -p $(build_folder)
	cp "$$($(swift_build) --show-bin-path)/$(program_name)" $@

# Universal (x86_64 + arm64) binary, as shipped in GitHub releases.
# arm64 macOS starts at 11.0, so that slice can't target 10.15.
universal:
	$(swift_build) --triple $(x86_64_triple)
	$(swift_build) --triple $(arm64_triple)
	mkdir -p $(build_folder)
	lipo -create -output $(binary) \
		"$$($(swift_build) --triple $(x86_64_triple) --show-bin-path)/$(program_name)" \
		"$$($(swift_build) --triple $(arm64_triple) --show-bin-path)/$(program_name)"

test:
	swift test

images:
	mkdir -p $(image_folder)
	cp images/*.png $(image_folder)

install: $(binary)
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 $(build_folder)/$(program_name) $(DESTDIR)$(PREFIX)/bin/$(program_name)

clean:
	rm -rf $(build_folder) .build
