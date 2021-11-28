import std/httpclient

import vr/cli


proc main() =
  let userInput = handleUserInput()

  echo userInput.limit
  echo userInput.attacheables

  let client = newHttpClient()

  let url = "https://caian-org.s3.amazonaws.com/public.gpg"
  let response = client.request(url, httpMethod = HttpGet)

  echo response.code



when isMainModule:
  main()
