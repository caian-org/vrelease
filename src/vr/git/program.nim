import std/sequtils
import std/strutils

import ../cli/logger
import ../util/command


type
  GitProtocol = enum
    HTTP, HTTPS, SSH

  GitProvider = enum
    GitHub, GitLab

type
  Git = object
    logger: Logger

  GitRemote = object
    protocol   *: GitProtocol
    uri        *: string
    username   *: string
    repository *: string


func newGitInterface* (logger: Logger): Git =
  return Git(logger : logger)

proc parseRemoteUrl (url: string): GitRemote =
  return GitRemote(
    protocol   : GitProtocol.HTTP,
    uri        : url,
    username   : "",
    repository : "",
  )

proc getRemoteInfo* (g: Git): seq[GitRemote] =
  let (gitRemoteRaw, _) = execCmd("git remote get-url --all origin")
  let gitRemotes = gitRemoteRaw.split("\n").mapIt(strip(it)).filterIt(len(it) > 0)

  g.logger.info(format("Found $1 remote(s) for this project", len(gitRemotes)))
  if len(gitRemotes) == 0:
    return @[]

  for i, r in gitRemotes:
    g.logger.debug(format("git_remote_info_$1", i + 1), gitRemotes[i])

  return gitRemotes.mapIt(parseRemoteUrl(it))
