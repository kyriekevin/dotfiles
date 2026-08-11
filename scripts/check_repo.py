#!/usr/bin/env python3
"""Deterministic source checks shared by local development and CI."""

import json
import re
import subprocess
import tempfile
import urllib.parse
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LINK_RE = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
REPOSITORY_ONLY = {
    ".github",
    ".gitignore",
    ".pre-commit-config.yaml",
    "AGENTS.md",
    "Brewfile",
    "CONTRIBUTING.md",
    "CONTRIBUTING_zh-CN.md",
    "LICENSE",
    "Makefile",
    "README.md",
    "README_zh-CN.md",
    "bootstrap.sh",
    "docs",
    "scripts",
    "tests",
}


def repository_files():
    result = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
        cwd=ROOT,
        check=True,
        capture_output=True,
    )
    return [ROOT / path.decode() for path in result.stdout.split(b"\0") if path]


def run(command, label, errors, *, stdin=None):
    try:
        result = subprocess.run(
            command,
            cwd=ROOT,
            input=stdin,
            text=True,
            capture_output=True,
        )
    except OSError as exc:
        errors.append(f"{label}: cannot run {command[0]}: {exc}")
        return ""
    if result.returncode:
        detail = (result.stderr or result.stdout).strip()
        errors.append(f"{label}: {detail or 'command failed'}")
    return result.stdout


def check_json(files, errors):
    for path in files:
        if path.suffix != ".json":
            continue
        try:
            json.loads(path.read_text(encoding="utf-8"))
        except (OSError, UnicodeError, json.JSONDecodeError) as exc:
            errors.append(f"{path.relative_to(ROOT)}: invalid JSON: {exc}")


def check_shell(files, errors):
    for path in files:
        relative = path.relative_to(ROOT)
        if path.suffix == ".sh":
            run(["bash", "-n", str(relative)], str(relative), errors)
        elif path.suffix == ".zsh" or path.name in {"dot_zshenv", "dot_zshrc"}:
            run(["zsh", "-n", str(relative)], str(relative), errors)


def check_templates(files, errors):
    templates = [path for path in files if path.name.endswith(".tmpl")]
    with tempfile.TemporaryDirectory(prefix="dotfiles-verify-") as temp:
        temp_path = Path(temp)
        common = [
            "chezmoi",
            "--no-tty",
            "--config",
            "/dev/null",
            "--config-format",
            "toml",
            "--persistent-state",
            str(temp_path / "state.boltdb"),
            "--cache",
            str(temp_path / "cache"),
            "--destination",
            str(temp_path / "home"),
            "--source",
            str(ROOT),
            "--override-data",
            '{"git_email":"ci@example.invalid","is_work":false}',
            "execute-template",
        ]
        for path in templates:
            relative = path.relative_to(ROOT)
            command = common + (["--init"] if path.name == ".chezmoi.toml.tmpl" else [])
            rendered = run(command + ["--file", str(relative)], str(relative), errors)
            if path.name.endswith(".sh.tmpl") and rendered:
                run(["bash", "-n"], f"{relative} rendered shell", errors, stdin=rendered)
            elif path.name == "dot_gitconfig.tmpl" and rendered:
                run(
                    ["git", "config", "--file", "-", "--list"],
                    f"{relative} rendered config",
                    errors,
                    stdin=rendered,
                )
            elif path.name == ".chezmoi.toml.tmpl" and rendered:
                rendered_config = temp_path / "rendered-chezmoi.toml"
                rendered_config.write_text(rendered, encoding="utf-8")
                run(
                    [
                        "chezmoi",
                        "--no-tty",
                        "--config",
                        str(rendered_config),
                        "--config-format",
                        "toml",
                        "--persistent-state",
                        str(temp_path / "validate-state.boltdb"),
                        "--cache",
                        str(temp_path / "validate-cache"),
                        "--destination",
                        str(temp_path / "home"),
                        "--source",
                        str(ROOT),
                        "data",
                    ],
                    f"{relative} rendered config",
                    errors,
                )


def check_bilingual_docs(errors):
    docs = ROOT / "docs"
    for path in docs.glob("*.md"):
        if path.name.endswith("_zh-CN.md"):
            partner = path.with_name(path.name.removesuffix("_zh-CN.md") + ".md")
        else:
            partner = path.with_name(path.stem + "_zh-CN.md")
        if not partner.exists():
            errors.append(f"{path.relative_to(ROOT)}: missing bilingual partner {partner.name}")


def check_chezmoi_boundary(errors):
    ignored = {
        line.strip()
        for line in (ROOT / ".chezmoiignore").read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    }
    missing = sorted(REPOSITORY_ONLY - ignored)
    if missing:
        errors.append(".chezmoiignore: repository-only paths not ignored: " + ", ".join(missing))


def check_markdown_links(files, errors):
    for path in files:
        if path.suffix != ".md":
            continue
        for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            for raw_target in LINK_RE.findall(line):
                target = raw_target.strip().split()[0].strip("<>")
                if target.startswith(("http://", "https://", "mailto:", "#", "/", "$")):
                    continue
                target = urllib.parse.unquote(target.split("#", 1)[0].split("?", 1)[0])
                if target and not (path.parent / target).resolve().exists():
                    relative = path.relative_to(ROOT)
                    errors.append(f"{relative}:{line_number}: missing link target {target}")


def main():
    errors = []
    files = repository_files()
    check_json(files, errors)
    check_shell(files, errors)
    check_templates(files, errors)
    check_bilingual_docs(errors)
    check_chezmoi_boundary(errors)
    check_markdown_links(files, errors)
    run(["git", "diff", "--check", "HEAD", "--"], "git diff --check", errors)

    if errors:
        print("Repository verification failed:")
        for error in errors:
            print(f"  - {error}")
        return 1
    print("Repository verification passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
