import std/os
import std/strformat
import std/strutils
import system

import src/vr/util/str
import src/vr/util/command


proc getLastTag(): string =
  let (output, _) = execOrPanic("git tag --sort=-creatordate")
  let tags = output.split("\n")

  if len(tags) > 0:
    let mostRecentTag = tags.first().strip()
    if mostRecentTag != "":
      return mostRecentTag

  return "UNRELEASED"

proc getLastCommitHash(): string =
  let (output, _) = execOrPanic("git rev-parse --short HEAD")
  return output.strip()

proc main() =
  let srcDir = absolutePath(joinPath("src", "vr"))
  let metaFileSrc = srcDir.joinPath("_meta")
  let metaFileOut = srcDir.joinPath("meta.nim")

  let lastTag = getLastTag()
  let lastCommitHash = getLastCommitHash()

  let m = &"""
  * reading from: {metaFileSrc}
  * writing to:   {metaFileOut}

  * program_version: {lastTag}
  * commit_hash:     {lastCommitHash}
  """

  echo m

  let content =
    "# This file is auto-generated\n" &
    readFile(metaFileSrc)
      .replace("@programVersion", lastTag)
      .replace("@commitHash", lastCommitHash)

  metaFileOut.writeFile(content)


when isMainModule:
  main()
