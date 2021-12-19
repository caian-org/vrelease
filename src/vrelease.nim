import std/os
import std/strutils
import std/httpclient

import vr/fn
import vr/meta
import vr/cli/parser
import vr/cli/logger
import vr/git/program
import vr/util/file
import vr/util/command


const authTokenEnvKey = "VRELEASE_AUTH_TOKEN"

func getAuthTokenFromEnv (): (bool, string) =
  if existsEnv(authTokenEnvKey):
    let e = getEnv(authTokenEnvKey).strip()
    if len(e) > 0:
      return (false, e)

  return (true, "")

proc processAttacheables (attacheables: seq[string], addChecksum: bool): seq[Attacheable] =
  attacheables.mapC(
    proc (i: int, a: string): Attacheable =
      echo i
      let p = resolveAssetPath(a)
      return Attacheable(
        filepath : p,
        hash     : if addChecksum: calculateSHA256ChecksumOf(p) else: ""
      )
  )

proc main () =
  let userInput = handleUserInput()

  let logger = newLogger(userInput.verbose, userInput.noColor)
  logger.debug("flag_verbose",         $userInput.verbose)
  logger.debug("flag_no_color",        $userInput.noColor)
  logger.debug("flag_add_checksum",    $userInput.addChecksum)
  logger.debug("flag_add_description", $userInput.addDescription)
  logger.debug("flag_pre_release",     $userInput.preRelease)
  logger.debug("flag_limit",           $userInput.limit)
  logger.debug("flag_attach",          $userInput.attacheables)

  displayStartMessage(userInput.noColor)

  let attacheables = userInput.attacheables.processAttacheables(addChecksum = userInput.addChecksum)
  echo attacheables

  # ---
  let (gitVersion, gitExitCode) = execCmd("git --version", panicOnError = false)
  if gitExitCode > 0:
    raise newException(Defect, "Could not find git. Are you sure it is installed and accessible on PATH?")

  logger.info("Using " & gitVersion.strip())
  let git = newGitInterface(logger)

  # ---
  let (tokenIsMissing, authToken) = getAuthTokenFromEnv()
  if tokenIsMissing:
    raise newException(Defect, format("Authorization token is undefined. Did you forgot to export '$1'?", authTokenEnvKey))

  # ---


  # ---
  let remotes = git.getRemoteInfo()
  if len(remotes) == 0:
    logger.info("Nothing to do, exiting early")
    return

  # ---

  let client = newHttpClient()

  let url = "https://caian-org.s3.amazonaws.com/public.gpg"
  let response = client.request(url, httpMethod = HttpGet)
  logger.debug("response_code", $response.code)


when isMainModule:
  main()
