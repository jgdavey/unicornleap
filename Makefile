CFLAGS += -std=c99 -fobjc-arc
LDFLAGS += -framework Cocoa -framework QuartzCore

unicornleap: main
	mkdir -p build
	mv main build/unicornleap

clean:
	  rm -f *.o build/
