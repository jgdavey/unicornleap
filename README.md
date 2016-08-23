# Unicornleap

A reimplementaion of KevinLiddle/unicornleap using CoreAnimation, now in Swift!
Requires OS X 10.9 or greater.

## Installation

The preferred installation uses make:

```
make
make install
```

By default, this will install to `/user/local`, but you can change that with the
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

# herd mode!
unicornleap -n 5 -s 0.5

# witness the majesty
unicornleap -s 4
```

## Supply Images

Unicorns leaping across your screen is great and all, but you can also supply
your own images:

```
# given these two images:
#   ~/.unicornleap/mario.png
#   ~/.unicornleap/coin.png
unicornleap -u mario.png -k coin.png
```

The only limits are your imagination! You and your friends will just laugh and
laugh!! <3 <3 <3
