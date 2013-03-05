CFLAGS += -std=c99 -fobjc-arc
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
	  rm -f *.o build/
