# Unicornleap

A reimplementation of KevinLiddle/unicornleap using CoreAnimation, now in Swift!

Runs on macOS 10.15 or later (Intel) / macOS 11 or later (Apple Silicon).
Building from source needs only the Xcode Command Line Tools
(`xcode-select --install`, Swift 6 or later), not the full Xcode. The first
build downloads one dependency, swift-argument-parser.

## Installation

### With mise

[mise](https://mise.jdx.dev)'s GitHub backend can install the prebuilt release
binary directly:

```
mise use -g github:jgdavey/unicornleap
```

To install a specific version (including prereleases), add it after `@`, e.g.
`mise use -g github:jgdavey/unicornleap@3.0.0-pre`.

### From a release

Grab the universal (Intel + Apple Silicon) tarball from the
[GitHub releases](https://github.com/jgdavey/unicornleap/releases), unpack it,
and put the binary on your `PATH`. The default images are built into the binary,
so there's nothing else to set up:

```
mkdir unicornleap && cd unicornleap
curl -L https://github.com/jgdavey/unicornleap/releases/download/v<version>/unicornleap-<version>-macos-universal.tar.gz | tar xz
mv unicornleap ~/.local/bin/
```

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

To change the defaults, put your own PNGs at `~/.unicornleap/unicorn.png` and/or
`~/.unicornleap/sparkle.png`; they take precedence over the built-in images.

The only limits are your imagination! You and your friends will just laugh and
laugh!! <3 <3 <3
