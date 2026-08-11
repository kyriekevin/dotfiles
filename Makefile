PYTHON ?= python3
PRE_COMMIT ?= pre-commit

.PHONY: verify check-repo check-pr-title pre-commit health help

help:
	@printf '%s\n' \
	  'make verify              repository checks used by CI' \
	  'make health PACKAGE=zsh  live health check on an applied Mac' \
	  'make check-pr-title TITLE="feat(zsh): add alias"'

verify: pre-commit check-repo

pre-commit:
	@git ls-files --cached --others --exclude-standard -z | \
	  xargs -0 $(PRE_COMMIT) run --show-diff-on-failure --files

check-repo:
	$(PYTHON) scripts/check_repo.py

check-pr-title:
	$(PYTHON) scripts/check_pr_title.py "$(TITLE)"

health:
	@test -n "$(PACKAGE)" || { echo 'usage: make health PACKAGE=<name>'; exit 2; }
	@test -f "tests/$(PACKAGE).sh" || { echo "unknown package: $(PACKAGE)"; exit 2; }
	bash "tests/$(PACKAGE).sh"
