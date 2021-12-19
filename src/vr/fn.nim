import std/sugar


func mapC* [T, S](vals: seq[T], callback: (i: int, v: T) -> S): seq[S] =
  var r: seq[S] = @[]
  for i, val in vals:
    r.add(callback(i, val))

  return r
