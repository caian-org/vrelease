import ../attacheable
import ../git/program


type Release* = object
  remote     *: GitRemote
  token      *: string
  body       *: string
  assets     *: seq[Attacheable]
  preRelease *: bool


proc create* (rel: Release) =
  discard ""
