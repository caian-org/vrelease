import std/sugar
import std/sequtils
import std/strutils
import std/terminal

import ../text


type
  Logger* = object
    isVerbose : bool
    noColors  : bool


proc log (g: Logger, txt: string, toStyle: (string) -> string, newLine = true) =
  let preffix = "=> "

  if g.noColors:
    stdout.write(preffix, txt)
  else:
    stdout.styledWrite(preffix.toStyle(), txt)

  if newLine:
    stdout.write("\n")

proc info* (g: Logger, txt: string, emph: varargs[string, `$`]) =
  let t = (
    if len(emph) > 0: format(txt, emph.map((e) => (if g.noColors: e else: e.toBrightCyanColor())))
    else: txt
  )

  g.log(t, (v: string) => v.toBrightBlueColor())

proc debug* (g: Logger, key: string, txt: string) =
  let preffix = ["===> ", "[DEBUG] "]

  if not g.isVerbose:
    return

  if g.noColors:
    stdout.write(preffix.join(""), format("$1 = $2", key, txt), "\n")
    return

  let a = preffix[0].toDimStyle()
  let b = preffix[1].toBoldStyle()
  stdout.write(a, b, key, " = ".toBrightRedColor(), txt, "\n")

proc getLogger* (isVerbose: bool = false, noColors: bool = false): Logger =
  var hasBeenInitialized {.global.} = false
  var logger {.global.}: Logger

  if hasBeenInitialized:
    return logger

  hasBeenInitialized = true
  logger = Logger(isVerbose : isVerbose, noColors : noColors)

  return logger
