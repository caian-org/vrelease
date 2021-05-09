[![Build][gh-build-shield]][gh-build-url]
[![Test][gh-test-shield]][gh-test-url]
[![Release][gh-release-shield]][gh-release-url]
[![Tag][tag-shield]][tag-url]

# `vrelease`

<img src="icon.svg" height="240px" align="right"/>

`vrelease` is a lightweight and straightforward release tool for GitHub and
GitLab (soon). It is packed as a single binary that requires no configuration
file and weights around 100kb on Linux/MacOS and 300kb on Windows. This project
is also:

- **Simple.** All required paramenters are detected automatically.
- **Minimal.** Only `git` and `curl` are required for execution.
- **Agnostic.** Idealized as a language independent alternative of [`goreleaser`][goreleaser].
- **CI/CD ready.** Designed to be integrated in CI/CD pipelines of any provider.

[gh-build-shield]: https://img.shields.io/github/workflow/status/caian-org/vrelease/build?label=build&logo=github&style=flat-square
[gh-build-url]: https://github.com/caian-org/vrelease/actions/workflows/build-many.yml

[gh-test-shield]: https://img.shields.io/github/workflow/status/caian-org/vrelease/test?label=test&logo=github&style=flat-square
[gh-test-url]: https://github.com/caian-org/vrelease/actions/workflows/test-many.yml

[gh-release-shield]: https://img.shields.io/github/workflow/status/caian-org/vrelease/release?label=release&logo=github&style=flat-square
[gh-release-url]: https://github.com/caian-org/vrelease/actions/workflows/release-all.yml

[tag-shield]: https://img.shields.io/github/tag/caian-org/vrelease.svg?logo=git&logoColor=FFF&style=flat-square
[tag-url]: https://github.com/caian-org/vrelease/releases

[goreleaser]: https://github.com/goreleaser/goreleaser


## License

To the extent possible under law, [Caian Rais Ertl][me] has waived __all
copyright and related or neighboring rights to this work__. In the spirit of
_freedom of information_, I encourage you to fork, modify, change, share, or do
whatever you like with this project! [`^C ^V`][kopimi]

[![License][cc-shield]][cc-url]

[me]: https://github.com/caiertl
[cc-shield]: https://forthebadge.com/images/badges/cc-0.svg
[cc-url]: http://creativecommons.org/publicdomain/zero/1.0

[kopimi]: https://kopimi.com
