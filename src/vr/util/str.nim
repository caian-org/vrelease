import std/terminal


func toColor (t: string, color: ForegroundColor, bright: bool): string =
  return ansiForegroundColorCode(color, bright = bright) & t & ansiResetCode

func toBrightBlueColor* (t: string): string =
  return t.toColor(fgBlue, true)

func toBrightRedColor* (t: string): string =
  return t.toColor(fgRed, true)

func toDimStyle* (t: string): string =
  return ansiStyleCode(styleDim) & t & ansiResetCode

func toBoldStyle* (t: string): string =
  return ansiStyleCode(styleBright) & t & ansiResetCode

func first* (t: seq[string]): string =
  return t[0]

func last* (t: seq[string]): string =
  return t[-1]
