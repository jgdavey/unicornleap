program_name := unicornleap
image_folder := $(HOME)/.$(program_name)

CFLAGS += -std=c99
LDFLAGS += -framework Cocoa -framework QuartzCore
PREFIX ?= /usr/local

.PHONY: all clean

all: $(program_name)

$(program_name): main
	@ mkdir -p build
	cp main build/$(program_name)

install: $(program_name) $(image_folder)
	cp build/$(program_name) ${PREFIX}/bin
	cp $(program_name).1 $(PREFIX)/share/man/man1/

$(image_folder):
	mkdir -p $@
	cp *.png $@

clean:
	@- $(RM) main
	@- $(RM) build/$(program_name)
