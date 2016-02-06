import Cocoa

func printUsage() {
  print(
    "Usage: unicornleap [options]\n",
    "  -h  --help           Display this usage information.\n",
    "  -s  --seconds n      Animate for n seconds. (default: 2.0)\n",
    "  -n  --number i       Display i unicorns. (default: 1)\n",
    "  -u  --unicorn file   Filename to use for unicorn image.\n",
    "  -k  --sparkle file   Filename to use for sparkle image.\n",
    "  -v  --verbose        Print verbose messages."
  )

  exit(0)
}

let command = Command(Process.arguments)

if command.needsHelp {
  printUsage()
}