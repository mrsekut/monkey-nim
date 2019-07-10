# Package

version       = "0.1.0"
author        = "mrsekut"
description   = "Implementing the Monkey language interpreter and compiler in Nim."
license       = "MIT"
srcDir        = "src"
bin           = @["monkey_nim"]

# Dependencies

requires "nim >= 0.19.2"
skipDirs = @["tests"]
