import std/unittest

import mainimpl


suite "Module 'mainimpl'":
  test "semver tag filter":
    let v = @["v1.0.0", "v1_0_0"]
    check filterSemver(v) == @["v1.0.0"]
