import std/osproc
import std/sugar
import std/strutils


proc execCmd* (cmd: string, panicOnError = true): (string, int) =
  let (output, exitCode) = execCmdEx(cmd)

  if panicOnError and exitCode > 0:
    let co = if len(output) > 0: format("; got:\n\n$1", output) else: ""
    let msg = format("command '$1' failed with return code $2", cmd, exitCode) & co

    raise newException(Defect, msg)

  return (output, exitCode)

proc die* (msg: string, args: varargs[string, `$`]) =
  raise newException(Defect, format(msg, args))

func mapC* [T, S](vals: seq[T], callback: (i: int, v: T) -> S): seq[S] =
  var r: seq[S] = @[]
  for i, val in vals:
    r.add(callback(i, val))

  return r
