import std/osproc
import std/strformat


proc execOrPanic*(cmd: string): (string, int) =
  let (output, exitCode) = execCmdEx(cmd)

  if exitCode > 0:
    let co = if len(output) > 0: &"; got: \n\n{output}" else: ""
    raise newException(Defect, &"command '{cmd}' failed with return code {exitCode} {co}")

  return (output, exitCode)
