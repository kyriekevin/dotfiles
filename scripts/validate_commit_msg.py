import re
import sys


def validate_commit_msg(message):
    lines = message.strip().split("\n")
    if not lines:
        return False

    first_line = lines[0]
    title_pattern = r"^(fix|feat|wip|breaking|docs|style|refactor|perf|test|chore|bump)(\(.+\))?: .{1,100}$"
    if not re.match(title_pattern, first_line):
        print("Error: Commit title format is incorrect.")
        print("It should match: <type>(<scope>): <subject>")
        print("Example: feat(auth): add login feature")
        return False

    if len(lines) == 1:
        return True

    body_started = False
    footer_started = False

    for line in lines[1:]:
        if not body_started and line.strip():
            body_started = True
        elif body_started and not line.strip() and not footer_started:
            footer_started = True
        elif footer_started and line.strip():
            footer_pattern = r"^(BREAKING CHANGE: |\w+: )"
            if not re.match(footer_pattern, line):
                print("Error: Footer format is incorrect.")
                print("It should start with 'BREAKING CHANGE: ' or '<type>: '")
                return False

    return True


if __name__ == "__main__":
    commit_msg_file = sys.argv[1]
    with open(commit_msg_file, "r") as f:
        commit_msg = f.read()

    if not validate_commit_msg(commit_msg):
        sys.exit(1)
