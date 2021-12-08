import std/strutils


proc die* (msg: string, args: varargs[string, `$`]) =
  raise newException(Defect, format(msg, args))
