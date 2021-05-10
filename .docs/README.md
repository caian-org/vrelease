[![Build][gh-build-shield]][gh-build-url]
[![Test][gh-test-shield]][gh-test-url]
[![Release][gh-release-shield]][gh-release-url]
[![Tag][tag-shield]][tag-url]

# `vrelease`

<img src=".docs/icon.svg" height="240px" align="right"/>

`vrelease` is a lightweight and straightforward release tool for GitHub and
GitLab. It is packed as a single binary that requires no configuration file and
weights around 100kb on Linux/MacOS and 300kb on Windows. This tool is also:

- **Simple.** All required paramenters are detected automatically
- **Minimal.** Only `git` and `curl` are required for execution
- **Agnostic.** Idealized as a language independent alternative for [`goreleaser`][goreleaser]
- **CI/CD ready.** Designed to be integrated in CI/CD pipelines of any provider

[gh-build-shield]: https://img.shields.io/github/workflow/status/caian-org/vrelease/build?label=build&logo=github&style=flat-square
[gh-build-url]: https://github.com/caian-org/vrelease/actions/workflows/build-many.yml

[gh-test-shield]: https://img.shields.io/github/workflow/status/caian-org/vrelease/test?label=test&logo=github&style=flat-square
[gh-test-url]: https://github.com/caian-org/vrelease/actions/workflows/test-many.yml

[gh-release-shield]: https://img.shields.io/github/workflow/status/caian-org/vrelease/release?label=release&logo=github&style=flat-square
[gh-release-url]: https://github.com/caian-org/vrelease/actions/workflows/release-all.yml

[tag-shield]: https://img.shields.io/github/tag/caian-org/vrelease.svg?logo=git&logoColor=FFF&style=flat-square
[tag-url]: https://github.com/caian-org/vrelease/releases

[goreleaser]: https://github.com/goreleaser/goreleaser


## Table of contents

- [How can I use it?](#how-can-i-use-it)
    - [Execution example](#execution-example)
    - [CI/CD examples](#cicd-examples)
    - [Help message](#help-message)
- [How can I get it?](#how-can-i-get-it)
- [Can I contribute?](#can-i-contribute)
- [License](#license)


## How can I use it?

`vrelease` is a tool that **generates releases on GitHub and GitLab**. It
should be used in the context of a CI/CD pipeline, at the delivery stage. The
pipeline should be declared in a way that, when a new tag is pushed, the tool
is executed after the tests passed, so a new release is automatically created
with changelog.

<br/>
<p align="center">
  <a href="https://asciinema.org/a/412861" target="_blank"><img src=".docs/demo.gif" height="400px"></a>
</p>
<br/>

The tool lists all the project's tags and compare the changes from the last tag
to the current one -- If no last tag is detected, it will use the master branch
as the last reference. It then formats the log to an HTML changelog and creates
on the provider via an API call. The username, repository name, connection
protocol (HTTPS or SSH) and provider (GitHub or GitLab) detection is based upon
the repository remote URL.

Optionally, one or more artifacts can be attached to the release. The title and
a message/description can also be added using the last commit that closes the
tag. The API authentication to either GitHub or GitLab is made by tokens. The
token should be generated for you account and exposed inside the pipeline via
the `VRELEASE_AUTH_TOKEN` environment variable.


### Execution example

[This commit][ex-commit] closes the `v1.1.0` tag of [this project][ex-proj].
When using the following command:

```sh
vrelease --add-checksum --add-description --attach my_artifact
```

The generated release looks [like this][ex-release]

[ex-commit]: https://github.com/vrelease/vrtp/commit/6174cf7f03f741e4652d70e85a633277ce5f1069
[ex-proj]: https://github.com/vrelease/vrtp
[ex-release]: https://github.com/vrelease/vrtp/releases/tag/v1.1.0


### CI/CD examples

*TODO*


### Help message

```

Usage: vrelease [flags]

KISS solution to easily create project releases

Flags:
  -a  --attach           attaches (uploads) a file to the release
  -i  --add-description  adds release description from last commit
  -c  --add-checksum     adds file integrity data (SHA256 checksum)
  -p  --pre-release      identifies the release as non-production ready
  -l  --limit            sets a limit to the amount of changelog lines
  -d  --debug            enables debug mode
  -n  --no-color         disables output with colors
  -h  --help             prints help information
  -v  --version          prints version information

```


## How can I get it?

`vrelease` is distributed in many pre-built forms:

- For NodeJS projects, use the [js-wrapper][vr-js];
- For Python projects, use the [py-wrapper][vr-py];
- For MacOS systems, use the [homebrew-formula][vr-brew];
- For Docker-based systems, use the [docker-image][vr-docker];
- For all other needs, download from the [releases page][vr-rels];

[vr-js]: https://github.com/vrelease/js-wrapper
[vr-py]: https://github.com/vrelease/py-wrapper
[vr-brew]: https://github.com/vrelease/homebrew-formula
[vr-docker]: https://github.com/vrelease/docker-image
[vr-rels]: https://github.com/vrelease/vrelease/releases

You can also build from source:

`vrelease` is implemented in [V][vlang], a language inspired by Golang, Rust
and Python that compiles to human-readable C. After downloading and installing
V, use make (see [`Makefile`][makefile]) with `release`:

```sh
make release
```

[vlang]: https://github.com/vlang/v
[makefile]: https://github.com/vrelease/vrelease/blob/master/Makefile


## Can I contribute?

Yes, contributions are welcomed. You can contribute with bugfixes and minor
features. For bigger, more complex features or architectural changes, please
contact me beforehand.

If you wish to contribute:

- Fork it (https://github.com/vrelease/vrelease/fork)
- Create your feature branch (`git checkout -b my-new-feature`)
- Commit your changes (`git commit -am 'Add some feature'`)
- Push to the branch (`git push origin my-new-feature`)
- Create a new Pull Request

Large contributions must contain a notice stating that the owner (i.e., the
contributor) waive it's copyrights to the Public Domain.


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
