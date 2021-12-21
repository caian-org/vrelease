import std/terminal


func first* (t: seq[string]): string = t[0]

func last* (t: seq[string]): string = t[len(t) - 1]

func toColor (t: string, color: ForegroundColor, bright: bool): string =
  ansiForegroundColorCode(color, bright = bright) & t & ansiResetCode

func toBrightBlueColor* (t: string): string =
  t.toColor(fgBlue, true)

func toBrightCyanColor* (t: string): string =
  t.toColor(fgCyan, true)

func toBrightRedColor* (t: string): string =
  t.toColor(fgRed, true)

func toDimStyle* (t: string): string =
  ansiStyleCode(styleDim) & t & ansiResetCode

func toBoldStyle* (t: string): string =
  ansiStyleCode(styleBright) & t & ansiResetCode

func atRelativeIndex* (t: seq[string], i: int): string =
  if i >= 0:
    return t[i]

  return t[len(t) + i]
