#!/usr/bin/env bash
# fastfetch Dev-block lume row. Emits:
#   line 1: lume --version output
#   line N: one indented sub-line per VM (tree-prefix ├/└), aligned to
#           fastfetch's display.key.width (21 cols).
# When no VMs or lume is missing, emits just the version / "(unavailable)".
#
# bash 3.2 compatible (macOS system shell) — no mapfile, no assoc arrays.
set -u

v=$(lume --version 2>/dev/null)
if [[ -z $v ]]; then
    echo "(unavailable)"
    exit 0
fi
echo "$v"

# Fastfetch prefixes every module line with \x1b[<logo_width>C to step past
# the logo, then positions the value via \x1b[<N>G where N = logo_width +
# key.width. Continuation lines emitted by a command get no such prefix —
# they start at absolute col 0 in the terminal. We re-align manually with
# CHA (\x1b[<col>G) so per-VM sub-lines land under the value column.
#
# For Apple logo (34 cols) + display.key.width (21) → value col = 55.
# If either changes in config.jsonc, bump VCOL to match.
VCOL=55
goto=$'\033['"${VCOL}G"

render_vms() {
    lume ls --format json 2>/dev/null | python3 -c '
import json, sys
try:
    vms = json.load(sys.stdin)
except Exception:
    sys.exit()
# lume ls --format json currently always returns a list; guard against
# a future API drift that emits an error object on stdout instead.
if not isinstance(vms, list):
    sys.exit()
GB = 1024 ** 3
def gb(x):
    # is-not-None, not truthiness: allocated=0 is a real state on freshly
    # created VMs and should render as "0G", not "?".
    return f"{x // GB}G" if x is not None else "?"
for v in vms:
    name   = v.get("name", "?")
    status = v.get("status", "?")
    cpu    = v.get("cpuCount", "?")
    disk   = v.get("diskSize") or {}
    used   = disk.get("allocated")
    total  = disk.get("total")
    ip     = v.get("ipAddress") or "-"
    net    = v.get("networkMode") or "-"
    loc    = v.get("locationName") or "-"
    mem_s  = gb(v.get("memorySize"))
    disk_s = f"{gb(used)}/{gb(total)}"
    extra  = f" \u00b7 {ip}" if ip != "-" else ""
    print(f"{name}: {status} \u00b7 {cpu}c/{mem_s} \u00b7 {disk_s} \u00b7 {net}/{loc}{extra}")
' 2>/dev/null
}

# Stream-format with ├/└ tree prefixes. Buffer one line so we know which is
# the last (gets └) vs intermediate (gets ├). Zero VMs → nothing emitted.
prev=""
while IFS= read -r line; do
    if [[ -n $prev ]]; then
        printf "%s├ %s\n" "$goto" "$prev"
    fi
    prev=$line
done < <(render_vms)
if [[ -n $prev ]]; then
    printf "%s└ %s\n" "$goto" "$prev"
fi
