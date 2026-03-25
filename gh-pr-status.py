#!/usr/bin/env uv run
"""Poll GitHub PRs (authored + adopted) and write a status emoji to a file. #ai-slop

Usage:
  gh-pr-status.py            # poll and write status
  gh-pr-status.py add <url>  # add an adopted PR URL to the watch list
  gh-pr-status.py remove <url>  # remove an adopted PR URL from the watch list
  gh-pr-status.py list       # show adopted PRs

Status file: ~/.local/share/gh-pr-status/status.txt
Adopted PRs: ~/.local/share/gh-pr-status/adopted.txt

oh-my-posh segment reads status.txt for ambient display.
"""

# /// script
# dependencies = []
# ///

import argparse
import json
import logging
import os
import re
import subprocess
import sys
from collections.abc import Iterator
from dataclasses import dataclass
from enum import Enum
from pathlib import Path


class PRStatus(Enum):
  """Possible reasons the PR author would need to return to their PR to take manual action."""

  # ! Important keep in sync with apps/github.pr.dash.md heading Status emoji
  CLOSED   = " 🚫"  # PR was closed without merging (auto-removed from adopted list)
  MERGED   = " ✅"  # PR has been merged (auto-removed from adopted list)
  WAITING  = ""    # pending review or CI in progress
  BEHIND   = " 🔄"  # branch is behind base, needs rebase/merge
  FAILING  = " ❌"  # has a failing/errored check
  REQUESTED = " 💬"  # changes requested
  APPROVED = " 👌"  # approved + CI passing, needs manual merge
  # last line is most important to show

  def __lt__(self, other: "PRStatus") -> bool:
    members = list(self.__class__)
    return members.index(self) < members.index(other)


@dataclass(frozen=True, order=True)
class PR:
  url: str
  repo: str
  number: int

  @staticmethod
  def parse(url: str) -> "PR | None":
    """Parse 'https://github.com/owner/repo/pull/123' into a PR."""
    m = re.match(r"https?://[^/]+/([^/]+/[^/]+)/pull/(\d+)", url)
    if not m:
      return None
    return PR(url=url, repo=m.group(1), number=int(m.group(2)))


DATA_DIR = Path.home() / ".local" / "share" / "gh-pr-status"
STATUS_FILE = DATA_DIR / "status.txt"
ADOPTED_FILE = DATA_DIR / "adopted.txt"


def _gh_run(*args: str, host: str | None = None) -> str | None:
  """Generic runner, allows for type checks to pass"""
  env = os.environ.copy()
  if host:
    env["GH_HOST"] = host
  result = subprocess.run(
    ["gh", *args],
    capture_output=True,
    text=True,
    env=env,
  )

  if logging.getLogger().isEnabledFor(logging.DEBUG):
    cleaned_file_name = re.sub(r"[^a-zA-Z0-9_.-]", "_", f"gh-{'-'.join(args)}"[:150])
    data_file = DATA_DIR / f"{cleaned_file_name}.json"
    data_file.write_text(result.stdout)
    logging.debug("Wrote %s", data_file)

  if result.returncode != 0:
    logging.warning("gh %s failed: %s", " ".join(args), result.stderr.strip())
    return None
  return result.stdout


def gh(*args: str, host: str | None = None) -> list[dict]:
  output = _gh_run(*args, host=host)
  if output is None:
    return []
  return json.loads(output)


def gh_one(*args: str, host: str | None = None) -> dict | None:
  """Like gh(), but expects a single JSON object response (e.g. gh pr view)."""
  output = _gh_run(*args, host=host)
  if output is None:
    return None
  return json.loads(output)


_UNRESOLVED_THREADS_QUERY = """
query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        nodes { isResolved isOutdated }
      }
    }
  }
}
"""


def fetch_unresolved_thread_count(pr: PR, host: str | None) -> int:
  """Return the number of active (not resolved, not outdated) review threads."""
  owner, repo_name = pr.repo.split("/", 1)
  result = gh_one(
    "api", "graphql",
    "--field", f"owner={owner}",
    "--field", f"repo={repo_name}",
    "--field", f"number={pr.number}",
    "--field", f"query={_UNRESOLVED_THREADS_QUERY}",
    host=host,
  )
  if result is None:
    logging.warning("Could not fetch review threads for %s#%d", pr.repo, pr.number)
    return 0
  threads = result.get("data", {}).get("repository", {}).get("pullRequest", {}).get("reviewThreads", {}).get("nodes", [])
  count = sum(1 for t in threads if not t.get("isResolved") and not t.get("isOutdated"))
  logging.debug("%s#%d has %d unresolved thread(s)", pr.repo, pr.number, count)
  return count


def classify_pr(pr: dict) -> Iterator[PRStatus]:
  """Yield all applicable PRStatus values; caller uses max(..., default=WAITING).
  See docs: https://docs.github.com/en/enterprise-cloud@latest/graphql/reference/enums#mergestatestatus"""
  if pr.get("state") == "MERGED":
    yield PRStatus.MERGED
    return  # no further checks make sense for a merged PR
  if pr.get("state") == "CLOSED":
    yield PRStatus.CLOSED
    return  # no further checks make sense for a merged PR

  if pr.get("mergeStateStatus") == "BEHIND":
    yield PRStatus.BEHIND

  # DONT check REVIEW_REQUIRED — waiting on a reviewer to weigh in is not actionable.
  if pr.get("reviewDecision") == "CHANGES_REQUESTED":
    # Only actionable if the reviewer hasn't been re-requested yet.
    # After re-requesting, the reviewer appears in reviewRequests while
    # reviewDecision stays CHANGES_REQUESTED until they re-review.
    re_requested = {r.get("login") for r in (pr.get("reviewRequests") or [])}
    changes_requested_by = {
      r["author"]["login"]
      for r in (pr.get("reviews") or [])
      if r.get("state") == "CHANGES_REQUESTED"
    }
    if changes_requested_by - re_requested:
      yield PRStatus.REQUESTED

  if pr.get("unresolved_thread_count", 0) > 0:
    yield PRStatus.REQUESTED

  checks = pr.get("statusCheckRollup") or []
  conclusions = {c.get("conclusion") or c.get("status") for c in checks}

  if conclusions & {"FAILURE", "ERROR", "TIMED_OUT"}:
    yield PRStatus.FAILING

  ci_passing = not (conclusions & {"IN_PROGRESS", "QUEUED", "PENDING"})
  if pr.get("reviewDecision") == "APPROVED" and ci_passing:
    yield PRStatus.APPROVED


# MAYBE: For PRs waiting on a reviewer, show how long they've been waiting since
# the review was (re-)requested — so you know whether it's worth pinging them.
# Different teams have different norms (Slack DM, Jira comment, etc.), but the
# raw "hours waiting" number is the input to that decision.
#
# Example output goal:
#   💬  https://github.com/owner/repo/pull/42  (reviewer-alice for 19h)
#   💬  https://github.com/owner/repo/pull/99  (reviewer-bob for 3d)
#
# Approaches tried that give wrong answers:
#
# 1. submittedAt of the latest CHANGES_REQUESTED review — WRONG
#    Gives the time the reviewer blocked the PR (e.g. 6d ago), not when
#    you re-requested after addressing their feedback. Re-requesting does
#    not create a new review entry in the `reviews` JSON field.
#
# 2. committedDate of the latest commit — WRONG
#    A base-branch merge commit (e.g. "Merge branch 'main' into feature")
#    can be pushed *after* the re-request for unrelated reasons, making
#    the timer look like 2h when the reviewer has actually had it for 19h.
#
# Correct data source: the ReviewRequestedEvent in the PR timeline, which
# is exactly what GitHub shows as "author requested a review from reviewer N hours ago".
#
# Follow-up: use `gh api graphql` to fetch the timeline event:
#   query {
#     repository(owner: "OWNER", name: "REPO") {
#       pullRequest(number: NUMBER) {
#         timelineItems(last: 50, itemTypes: [REVIEW_REQUESTED_EVENT]) {
#           nodes {
#             ... on ReviewRequestedEvent {
#               createdAt
#               requestedReviewer { ... on User { login } }
#             }
#           }
#         }
#       }
#     }
#   }
# `gh pr view --json` does not expose timelineItems; must use `gh api graphql`.


def fetch_pr_status(pr: PR) -> PRStatus:
  """Fetch a single PR's status via gh pr view."""
  data = gh_one(
    "pr",
    "view",
    str(pr.number),
    "--repo",
    pr.repo,
    "--json",
    "state,mergeStateStatus,reviewDecision,reviews,reviewRequests,statusCheckRollup",
  )
  if data is None:
    raise RuntimeError(f"Failed to fetch PR status for {pr.url}")

  data["unresolved_thread_count"] = fetch_unresolved_thread_count(pr, host)
  statuses = list(classify_pr(data))
  status = max(statuses, default=PRStatus.WAITING)
  logging.debug("%s#%d -> %s", pr.repo, pr.number, status)

  # Skip creating a "dash" in a cron job
  if sys.stdout.isatty():
    status_strings = [s.value.strip() for s in sorted(statuses) if s.value]
    padding = " " * 2 * (len(PRStatus) - len(statuses))
    reviewers = sorted(r.get("login") for r in data.get("reviewRequests", []))
    reviewer_str = f"({', '.join(reviewers)})" if reviewers else ""
    print("".join(status_strings) + padding, status.value or "   ", pr.url, reviewer_str)

    if sorted(statuses) == [PRStatus.BEHIND, PRStatus.APPROVED]:
      print("Suggested:")
      print("    gh pr update-branch", pr.url)
      # MAYBE automate this? but don't want to spam the CI pipeline? Maybe some sort of stateful rate-limiting, by repo? What if update fails on merge conflict?
  return status


def load_adopted() -> list[PR]:
  if not ADOPTED_FILE.exists():
    return []
  prs = []
  for line in ADOPTED_FILE.read_text().splitlines():
    url = line.strip()
    if not url:
      continue
    pr = PR.parse(url)
    if pr is None:
      logging.warning("Skipping invalid adopted URL: %s", url)
      continue
    prs.append(pr)
  return prs


def save_adopted(prs: list[PR]) -> None:
  DATA_DIR.mkdir(parents=True, exist_ok=True)
  ADOPTED_FILE.write_text("\n".join(pr.url for pr in prs) + "\n" if prs else "")


def cmd_add(url: str) -> None:
  pr = PR.parse(url)
  if pr is None:
    sys.exit(f"Invalid PR URL: {url}")
  adopted = load_adopted()
  if any(p.url == url for p in adopted):
    logging.info("Already watching: %s", url)
    return
  save_adopted([*adopted, pr])
  logging.info("Added: %s", url)


def cmd_remove(url: str) -> None:
  adopted = load_adopted()
  remaining = [pr for pr in adopted if pr.url != url]
  if len(remaining) == len(adopted):
    sys.exit(f"Not in watch list: {url}")
  save_adopted(remaining)
  logging.info("Removed: %s", url)


def cmd_list() -> None:
  adopted = load_adopted()
  if not adopted:
    logging.info("No adopted PRs.")
    return
  for pr in adopted:
    print(pr.url)


def cmd_poll() -> None:
  results: list[tuple[PRStatus, PR]] = []

  own_prs = gh("search", "prs", "--author=@me", "--state=open", "--json", "number,repository,url")
  logging.debug("Found %d own PRs", len(own_prs))
  for raw in own_prs:
    pr = PR(url=raw["url"], repo=raw["repository"]["nameWithOwner"], number=raw["number"])
    status = fetch_pr_status(pr)
    results.append((status, pr))

  adopted = load_adopted()
  done: list[tuple[PRStatus, PR]] = []
  for pr in adopted:
    status = fetch_pr_status(pr)
    results.append((status, pr))
    if status in (PRStatus.MERGED, PRStatus.CLOSED):
      done.append((status, pr))

  if done:
    done_prs = {pr for _, pr in done}
    save_adopted([pr for pr in adopted if pr not in done_prs])
    for status, pr in done:
      logging.info("Auto-removed %s %s adopted PR: %s", status.value.strip(), status.name.lower(), pr.url)

  actionable = [(s, pr) for s, pr in results if s not in (PRStatus.WAITING, PRStatus.MERGED, PRStatus.CLOSED)]
  if not actionable:
    STATUS_FILE.write_text("")
    logging.info("Wrote empty status to %s", STATUS_FILE)
    return

  top_status, top_pr = max(actionable)
  # OSC 8 escaped link https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
  content = f"\033]8;;{top_pr.url}\033\\{top_status.value}\033]8;;\033\\"
  STATUS_FILE.write_text(content)
  logging.info("Wrote %r linking to %s in %s", top_status.value, top_pr.url, STATUS_FILE)


def main() -> None:
  parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
  parser.add_argument("--loglevel", default="info", help="Logging level, e.g. --loglevel debug (default: info)")
  subparsers = parser.add_subparsers(dest="command")
  subparsers.add_parser("poll", help="Poll PRs and write status (default)")
  add_parser = subparsers.add_parser("add", help="Add an adopted PR URL to the watch list")
  add_parser.add_argument("url")
  remove_parser = subparsers.add_parser("remove", help="Remove an adopted PR URL from the watch list")
  remove_parser.add_argument("url")
  subparsers.add_parser("list", help="Show adopted PRs")

  args = parser.parse_args()
  logging.basicConfig(
    format="[%(asctime)s] {%(filename)s:%(lineno)d} %(levelname)s - %(message)s", level=args.loglevel.upper()
  )

  if args.command is None or args.command == "poll":
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    STATUS_FILE.write_text(" ⏳")
    cmd_poll()
  elif args.command == "add":
    cmd_add(args.url)
  elif args.command == "remove":
    cmd_remove(args.url)
  elif args.command == "list":
    cmd_list()


if __name__ == "__main__":
  main()
