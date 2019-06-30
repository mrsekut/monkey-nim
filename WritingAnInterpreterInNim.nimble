# Package

version       = "0.1.0"
author        = "mrsekut"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["Monkey-Nim"]

# Dependencies

requires "nim >= 0.18.0"
skipDirs = @["tests"]
