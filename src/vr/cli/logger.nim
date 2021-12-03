import std/strformat
import std/strutils
import std/sugar
import std/terminal

import ../util/str


type
  Logger = object
    isVerbose : bool
    noColors  : bool


proc log(g: Logger, txt: string, toStyle: (string) -> string, newLine = true) =
  let preffix = "=> "

  if g.noColors:
    stdout.write(preffix, txt)
  else:
    stdout.styledWrite(preffix.toStyle(), txt)

  if newLine:
    stdout.write("\n")

proc info*(g: Logger, txt: string) =
  g.log(txt, (v: string) => v.toBrightBlueColor())

proc debug*(g: Logger, key: string, txt: string) =
  let preffix = ["===> ", "[DEBUG] "]

  if not g.isVerbose:
    return

  if g.noColors:
    stdout.write(preffix.join(""), &"{key} = {txt}", "\n")
    return

  stdout.write(
    preffix[0].toDimStyle(),
    preffix[1].toBoldStyle(),
    key,
    " = ".toBrightRedColor(),
    txt,
    "\n"
  )

proc newLogger*(isVerbose: bool, noColors: bool): Logger =
  return Logger(
    isVerbose : isVerbose,
    noColors  : noColors
  )
