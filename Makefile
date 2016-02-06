program_name := unicornleap
image_folder := $(HOME)/.$(program_name)

CFLAGS += -std=c99
LDFLAGS += -framework Cocoa -framework QuartzCore
PREFIX ?= /usr/local

.PHONY: all clean

all: $(program_name)

$(program_name): unicornleap
	@ mkdir -p build
	cp unicornleap build/$(program_name)

install: $(program_name) $(image_folder)
	cp build/$(program_name) ${PREFIX}/bin
	cp $(program_name).1 $(PREFIX)/share/man/man1/

$(image_folder):
	mkdir -p $@
	cp images/*.png $@

clean:
	@- $(RM) unicornleap
	@- $(RM) build/$(program_name)
