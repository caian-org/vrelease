import std/sugar
import std/terminal


type
  Logger = object
    isVerbose : bool
    noColors  : bool

proc log(g: Logger, msg: string, toStyle: (string) -> string, newLine = true) =
  let preffix = "=> "

  if g.noColors:
    stdout.write(preffix, msg)
  else:
    stdout.styledWrite(preffix.toStyle(), msg)

  if newLine:
    stdout.write("\n")


func toBrightBlue (t: string): string =
  return ansiForegroundColorCode(fgBlue, bright = true) & t & ansiResetCode


proc info*(g: Logger, msg: string) =
  g.log(msg, (v: string) => v.toBrightBlue())


proc newLogger*(isVerbose: bool, noColors: bool): Logger =
  return Logger(
    isVerbose : isVerbose,
    noColors  : noColors
  )
