import std/times
import std/httpclient
import std/strformat
import std/strutils

import vr/cli/parser
import vr/cli/logger
import vr/util/str


proc displayStartMessage(noColor: bool, startedAt: string) =
  var started = &"program has started @ {startedAt}"

  if not noColor:
    started = started.toDimStyle()

  let m = ["", started, "", ""]
  stdout.write(m.join("\n"))


proc main() =
  let startedAt = now().format("yyyy-MM-dd HH:mm:ss")
  let userInput = handleUserInput()

  let logger = newLogger(userInput.verbose, userInput.noColor)
  logger.debug("flag_verbose",         $userInput.verbose)
  logger.debug("flag_no_color",        $userInput.noColor)
  logger.debug("flag_add_checksum",    $userInput.addChecksum)
  logger.debug("flag_add_description", $userInput.addDescription)
  logger.debug("flag_pre_release",     $userInput.preRelease)
  logger.debug("flag_limit",           $userInput.limit)
  logger.debug("flag_attach",          $userInput.attacheables)

  displayStartMessage(userInput.noColor, startedAt)

  # ---

  let client = newHttpClient()

  let url = "https://caian-org.s3.amazonaws.com/public.gpg"
  let response = client.request(url, httpMethod = HttpGet)

  logger.debug("response_code", $response.code)


when isMainModule:
  main()
