CFLAGS += -std=c99
LDFLAGS += -framework Cocoa -framework QuartzCore
PREFIX ?= /usr/local

.PHONY: unicornleap

unicornleap: main
	mkdir -p build
	cp main build/unicornleap

install: unicornleap
	cp unicorn.png ~/.unicorn.png
	cp build/unicornleap ${PREFIX}/bin

clean:
	  rm -f main build/*
