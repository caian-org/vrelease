import std/sequtils
import std/strutils
import std/sugar

import ../fn
import ../cli/logger
import ../util/command
import ../util/flow
import ../util/str


type
  GitProtocol = enum
    HTTP  = "HTTP",
    HTTPS = "HTTPS",
    SSH   = "SSH"

  GitProvider = enum
    GitHub = "GitHub",
    GitLab = "GitLab"

type
  Git = object
    logger: Logger

  GitRemote* = object
    provider   *: GitProvider
    protocol   *: GitProtocol
    username   *: string
    repository *: string


proc malformedUrlErr () =
  die("Malformed git remote URL")

func identifyRemoteProtocol (url: string): GitProtocol =
  let u = url.toLower()

  if u.startsWith("http://"):
    return GitProtocol.HTTP

  if u.startsWith("https://"):
    return GitProtocol.HTTPS

  return GitProtocol.SSH

func identifyRemoteProvider (domain: string): GitProvider =
  let u = domain.toLower()

  if u == "github.com":
    return GitProvider.GitHub

  if u == "gitlab.com":
    return GitProvider.GitLab

  die(format("Unsupported provider '$1'", domain))

func tryToSplit (url: string, sep: string): (string, string) =
  if not url.contains(sep):
    malformedUrlErr()

  let segs = url.split(sep)
  if len(segs) != 2:
    malformedUrlErr()

  var t = segs.last()
  if t.endsWith(".git"):
    t = t.split(".git").first()

  return (segs.first(), t)

func retrieveFromSshRemote (url: string): (string, string, string) =
  let (sshConn, afterProtocol) = url.tryToSplit(":")
  if not sshConn.contains("@"):
    malformedUrlErr()

  let domain = sshConn.split("@").last()
  let segs = afterProtocol.split("/")

  let
    username   = segs[0]
    repository = segs.last()

  return (domain, username, repository)

func retrievefromHttpRemote (url: string): (string, string, string) =
  let (_, afterProtocol) = url.tryToSplit("://")
  let segs = afterProtocol.split("/")

  let
    domain     = segs[0]
    username   = segs[1]
    repository = segs.last()

  return (domain, username, repository)

func identifyProviderUserAndRepo (url: string, protocol: GitProtocol): (GitProvider, string, string) =
  let (domain, username, repository) = (
    if protocol == GitProtocol.SSH: retrieveFromSshRemote(url)
    else: retrievefromHttpRemote(url)
  )

  let provider = identifyRemoteProvider(domain)
  return (provider, username, repository)

proc parseRemoteUrl (g: Git, i: int, url: string): GitRemote =
  let ns = (t: string) => format("git_remote_$1_$2", t, i + 1)

  g.logger.debug(ns("url"), url)

  let protocol = identifyRemoteProtocol(url)
  g.logger.debug(ns("protocol"), format("$1", protocol))

  let (provider, username, repository) = identifyProviderUserAndRepo(url, protocol)
  g.logger.debug(ns("provider"), format("$1", provider))
  g.logger.debug(ns("username"), username)
  g.logger.debug(ns("repository"), repository)

  return GitRemote(
    provider   : provider,
    protocol   : protocol,
    username   : username,
    repository : repository,
  )

proc getRemoteInfo* (g: Git): seq[GitRemote] =
  let (gitRemoteRaw, _) = execCmd("git remote get-url --all origin")
  let gitRemotes = gitRemoteRaw.split("\n").mapIt(strip(it)).filterIt(len(it) > 0)

  g.logger.info(format("Found $1 remote(s) for this project", len(gitRemotes)))
  if len(gitRemotes) == 0:
    return @[]

  return gitRemotes.mapC((i: int, url: string) => g.parseRemoteUrl(i, url))

func newGitInterface* (l: Logger): Git = Git(logger : l)
