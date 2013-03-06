program_name := unicornleap

CFLAGS += -std=c99
LDFLAGS += -framework Cocoa -framework QuartzCore
PREFIX ?= /usr/local

.PHONY: all clean

all: $(program_name)

$(program_name): main
	@ mkdir -p build
	cp main build/$(program_name)

install: $(program_name)
	test -f ~/.unicorn.png || cp unicorn.png ~/.unicorn.png
	cp build/$(program_name) ${PREFIX}/bin

clean:
	@- $(RM) main
	@- $(RM) build/$(program_name)
