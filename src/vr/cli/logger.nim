import std/sugar
import std/strutils
import std/terminal

import ../util/str


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

proc info* (g: Logger, txt: string) =
  g.log(txt, (v: string) => v.toBrightBlueColor())

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

func newLogger* (isVerbose: bool, noColors: bool): Logger =
  Logger(
    isVerbose : isVerbose,
    noColors  : noColors,
  )
