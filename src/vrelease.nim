import std/os
import std/sequtils
import std/strutils
import std/sugar
import std/httpclient

import vr/meta
import vr/misc
import vr/attacheable
import vr/cli/parser
import vr/cli/logger
import vr/git/program

import semver


proc checkAndGetAuthToken (): string =
  const key = "VRELEASE_AUTH_TOKEN"

  if existsEnv(key):
    let e = getEnv(key).strip()
    if len(e) > 0:
      return e

  let m = format("authorization token is undefined. Did you forgot to export '$1'?", key)
  raise newException(Defect, m)

proc checkForGit () =
  let logger = getLogger()

  let (gitVersion, gitExitCode) = execCmd("git --version", panicOnError = false)
  if gitExitCode > 0:
    raise newException(Defect, "could not find git. Are you sure it is installed and accessible on PATH?")

  logger.info("Using " & gitVersion.strip())

proc processAttacheables (attacheables: seq[string], addChecksum: bool): seq[Attacheable] =
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

func filterSemver (tags: seq[string]): seq[string] =
  tags.filter(
    proc (t: string): bool =
      try:
        discard parseVersion(t)
        return true
      except:
        return false
  )


proc main () =
  let userInput = handleUserInput()

  let logger = getLogger(userInput.verbose, userInput.noColor)
  logger.debug("flag_verbose",         $userInput.verbose)
  logger.debug("flag_no_color",        $userInput.noColor)
  logger.debug("flag_add_checksum",    $userInput.addChecksum)
  logger.debug("flag_add_description", $userInput.addDescription)
  logger.debug("flag_pre_release",     $userInput.preRelease)
  logger.debug("flag_limit",           $userInput.limit)
  logger.debug("flag_attach",          $userInput.attacheables)

  displayStartMessage(userInput.noColor)
  checkForGit()

  # ---
  let git = newGitInterface()
  let authToken = checkAndGetAuthToken()
  let attacheables = processAttacheables(userInput.attacheables, userInput.addChecksum)

  # ---
  let gitRemotes = git.getRemoteInfo()
  if len(gitRemotes) == 0:
    logger.info("unable to create releases due to missing git remote; exiting early...")
    return

  # ---
  let gitTags = git.getTags()
  logger.debug("git_tags", $gitTags)
  logger.debug("git_tags_count", $len(gitTags))

  # ---
  let semverTags = filterSemver(gitTags)
  logger.debug("git_tags_semver", $semverTags)
  logger.debug("git_tags_semver_count", $len(semverTags))

  if len(semverTags) < 2:
    logger.info("unable to create a changelog due to insufficient tags; exiting early...")
    return

  # ---
  let tagFrom = semverTags[1]
  let tagTo   = semverTags[0]
  logger.info("generating changelog from $1 to $2", tagFrom, tagTo)

  # ---
  let changelog = git.getCommmitsLog(tagFrom, tagTo)
  logger.debug("git_changelog", $changelog)
  logger.debug("git_changelog_count", $len(changelog))

  # ---
  let client = newHttpClient()

  let url = "https://caian-org.s3.amazonaws.com/public.gpg"
  let response = client.request(url, httpMethod = HttpGet)
  logger.debug("response_code", $response.code)


when isMainModule:
  main()
