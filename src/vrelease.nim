import std/strutils
import std/httpclient

import vr/meta
import vr/cli/parser
import vr/cli/logger
import vr/git/program

import mainimpl


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
