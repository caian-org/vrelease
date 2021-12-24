import std/strformat
import std/strutils

import ../meta
import ../helpers

import docopt


const
  flagLimit          = "--limit"
  flagAttach         = "--attach"
  flagAddChecksum    = "--add-checksum"
  flagAddDescription = "--add-description"
  flagPreRelease     = "--pre-release"
  flagNoColor        = "--no-color"
  flagVerbose        = "--verbose"

const doc = fmt"""
KISS solution to easily create project releases.

Usage:
  vrelease [--verbose] [-cdpn] [-l <size>] [-a <file>]...
  vrelease -h | --help | --version

Options:
  -l <size>, {flagLimit} <size>   Set a limit on changelog lines.
  -a <file>, {flagAttach} <file>  Attach a release asset.
  -c, {flagAddChecksum}          Add a file integrity section.
  -d, {flagAddDescription}       Add a release description section.
  -p, {flagPreRelease}           Release as non-production ready.
  -n, {flagNoColor}              Disable terminal output coloring.
  -h, --help                  Print this help message
  --version                   Show version information.
  {flagVerbose}                   Increase logging information.
"""

type
  UserInput = object
    limit          *: int
    attacheables   *: seq[string]
    addChecksum    *: bool
    addDescription *: bool
    preRelease     *: bool
    noColor        *: bool
    verbose        *: bool


proc verifyAndParseIntFlag (args: Table[string, Value], flag: string): int =
  if args[flag]:
    try:
      let val = parseInt($args[flag])
      if val < 1:
          die("flag '$1' must be greater than zero", flag)

      return val

    except ValueError:
      die("flag '$1' expects an integer", flag)

  return -1


proc handleUserInput* (): UserInput =
  let v = [getSignature(), getCompilationInfo()].join("\n")
  let args = docopt(doc, version = v)
  let limit = verifyAndParseIntFlag(args, flagLimit)

  return UserInput(
    limit          : verifyAndParseIntFlag(args, flagLimit),
    attacheables   : @(args[flagAttach]),
    addChecksum    : toBool(args[flagAddChecksum]),
    addDescription : toBool(args[flagAddDescription]),
    preRelease     : toBool(args[flagPreRelease]),
    noColor        : toBool(args[flagNoColor]),
    verbose        : toBool(args[flagVerbose]),
  )
