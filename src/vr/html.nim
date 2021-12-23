import attacheable
import git/program


type ReleaseBodyOptions* = object
  remote         *: GitRemote
  commits        *: seq[GitCommit]
  assets         *: seq[Attacheable]
  commitLimit    *: int
  addChecksum    *: bool
  addDescription *: bool


proc buildHTMLChangelog* (opts: ReleaseBodyOptions): string =
  return ""
