import std/os
import std/sequtils
import std/strutils
import std/sugar

import vr/attacheable
import vr/helpers
import vr/cli/logger

import semver


proc checkAndGetAuthToken* (): string =
  const key = "VRELEASE_AUTH_TOKEN"

  if existsEnv(key):
    let e = getEnv(key).strip()
    if len(e) > 0:
      return e

  let m = format("authorization token is undefined. Did you forgot to export '$1'?", key)
  raise newException(Defect, m)

proc checkForGit* () =
  let logger = getLogger()

  let (gitVersion, gitExitCode) = execCmd("git --version", panicOnError = false)
  if gitExitCode > 0:
    raise newException(Defect, "could not find git. Are you sure it is installed and accessible on PATH?")

  logger.info("Using " & gitVersion.strip())

proc processAttacheables* (attacheables: seq[string], addChecksum: bool): seq[Attacheable] =
  let logger = getLogger()

  return attacheables.mapC(
    proc (i: int, a: string): Attacheable =
      let ns = (t: string) => format("attacheable_$1_$2", t, i + 1)
      let attacheable = newAttacheable(a, addChecksum)

      logger.debug(ns("filepath"), attacheable.filepath)

      if addChecksum:
        logger.debug(ns("hash"), attacheable.hash)

      return attacheable
  )

func filterSemver* (tags: seq[string]): seq[string] =
  tags.filter(
    proc (t: string): bool =
      try:
        discard parseVersion(t)
        return true
      except:
        return false
  )
