import std/httpclient

import vr/cli/parser
import vr/cli/logger


proc main() =
  let userInput = handleUserInput()

  let logger = newLogger(userInput.verbose, userInput.noColor)
  logger.info($userInput.attacheables)

  # ---

  let client = newHttpClient()

  let url = "https://caian-org.s3.amazonaws.com/public.gpg"
  let response = client.request(url, httpMethod = HttpGet)

  logger.info($response.code)


when isMainModule:
  main()
