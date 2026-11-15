# Unicornleap

A reimplementaion of KevinLiddle/unicornleap using CoreAnimation, now in Swift!

Versions in the 1.x branch require OS X 10.9 or greater, and need at least XCode 7 to build.

Versions in the main branch require OS X 10.11 or greater, and need at least XCode 8 to build.

## Installation

### From a release

Grab the universal (Intel + Apple Silicon) tarball from the
[GitHub releases](https://github.com/jgdavey/unicornleap/releases), put the
binary on your `PATH`, and copy the default images into `~/.unicornleap`:

```
mkdir unicornleap && cd unicornleap
curl -L https://github.com/jgdavey/unicornleap/releases/download/v<version>/unicornleap-<version>-macos-universal.tar.gz | tar xz
mv unicornleap ~/.local/bin/
mkdir -p ~/.unicornleap && cp images/*.png ~/.unicornleap/
```

The tarball also includes the man page, `unicornleap.1`.

### From source

The preferred source installation uses make:

```
make
make install
```

By default, this will install to `/usr/local`, but you can change that with the
PREFIX env variable.

### Manual installation

If you really want to, you can install manually:

1. `make`
2.  Copy the binary from `build` folder to somewhere in your path
3.  Create 2 images at `~/.unicornleap/unicorn.png` and `~/.unicornleap/sparkle.png`

## Usage

Once installed, simply run `unicornleap` and behold: a unicorn will leap across
your screen!! Here are some other fun ones:

```
# need help?
unicornleap -h

# leap a bunch
unicornleap -n 5 -s 0.5

# herd mode!
unicornleap -H

# witness the majesty
unicornleap -s 4
```

## Supply Images

Unicorns leaping across your screen is great and all, but you can also supply
your own images:

```
unicornleap -u /path/to/mario.png -k /path/to/coin.png
```

The only limits are your imagination! You and your friends will just laugh and
laugh!! <3 <3 <3
