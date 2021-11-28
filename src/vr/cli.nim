import std/os
import std/sequtils
import std/strformat
import std/strutils

import docopt


const
  flagLimit          = "--limit"
  flagAttach         = "--attach"
  flagAddChecksum    = "--add-checksum"
  flagAddDescription = "--add-description"
  flagPreRelease     = "--pre-release"
  flagNoColor        = "--no-color"
  flagVerbose        = "--verbose"

const doc = &"""
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
  UserInput* = object
    limit          *: int
    attacheables   *: seq[string]
    addChecksum    *: bool
    addDescription *: bool
    preRelease     *: bool
    noColor        *: bool
    verbose        *: bool


proc die(msg: string) =
  raise newException(Defect, msg)

proc resolveAssetPath(p: string): string =
  let absolutePath = (if isAbsolute(p): p else: absolutePath(p))

  if fileExists(absolutePath):
    return absolutePath

  let r = &"'{p}'" & (if p != absolutePath: &" (resolved to '{absolutePath}')" else: "")
  die(&"asset path {r} does not exists")

proc verifyAndParseIntFlag(args: Table[string, Value], flag: string): int =
  if args[flag]:
    try:
      return parseInt($args[flag])
    except ValueError:
      die(&"flag '{flag}' expects an integer")

  return -1

proc handleUserInput*(): UserInput =
  let args = docopt(doc, version = "something")

  return UserInput(
    limit          : verifyAndParseIntFlag(args, flagLimit),
    attacheables   : @(args[flagAttach]).mapIt(resolveAssetPath(it)),
    addChecksum    : toBool(args[flagAddChecksum]),
    addDescription : toBool(args[flagAddDescription]),
    preRelease     : toBool(args[flagPreRelease]),
    noColor        : toBool(args[flagNoColor]),
    verbose        : toBool(args[flagVerbose])
  )
