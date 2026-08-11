#!/usr/bin/env python3
"""Validate the squash-merge title used for pull requests."""

import re
import sys


TITLE_RE = re.compile(
    r"^(feat|fix|chore|docs|refactor|test|perf|ci|build|style)"
    r"(\([a-z0-9][a-z0-9._/-]*\))?!?: \S.+$"
)


def main():
    title = sys.argv[1].strip() if len(sys.argv) == 2 else ""
    subject = title.split(": ", 1)[1] if ": " in title else ""
    starts_uppercase = subject[:1].isalpha() and subject[:1] != subject[:1].lower()
    if not TITLE_RE.fullmatch(title) or title.endswith(".") or starts_uppercase:
        print("PR title must follow Conventional Commits:", file=sys.stderr)
        print("  <type>(<scope>?): <subject>", file=sys.stderr)
        print("Example: feat(zsh): add project aliases", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
