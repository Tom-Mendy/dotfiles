#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
WIZARD="$REPO_ROOT/scripts/dual-boot-ubuntu-wizard.sh"
TEST_TMP=$(mktemp -d)
trap 'rm -rf -- "$TEST_TMP"' EXIT

mkdir -p "$TEST_TMP/bin"
printf '#!/usr/bin/env bash\nsleep 10\n' > "$TEST_TMP/bin/xdg-open"
chmod +x "$TEST_TMP/bin/xdg-open"

if ! timeout 2 env PATH="$TEST_TMP/bin:$PATH" bash -c '
  source <(sed "/^# STAGES/,\$d" "$1")
  open_url "https://example.invalid/test"
' _ "$WIZARD"; then
  printf 'FAIL: open_url waits for a blocking browser opener\n' >&2
  exit 1
fi

printf 'PASS: open_url returns without waiting for the browser opener\n'

mkdir -p "$TEST_TMP/home/Downloads" "$TEST_TMP/ventoy"
touch "$TEST_TMP/home/Downloads/ubuntu-test.iso"

HOME="$TEST_TMP/home"
SCRIPT_DIR="$TEST_TMP/script"
source <(sed '/^banner "Dual-boot/,$d' "$WIZARD")

FOUND_ISO=$(find_local_iso "ubuntu-test.iso")
if [[ $FOUND_ISO != "$TEST_TMP/home/Downloads/ubuntu-test.iso" ]]; then
  printf 'FAIL: find_local_iso did not detect the ISO in ~/Downloads\n' >&2
  exit 1
fi

copy_iso_to_ventoy "$FOUND_ISO" "$TEST_TMP/ventoy" "ubuntu-test.iso"
if [[ ! -f "$TEST_TMP/ventoy/ubuntu-test.iso" ]]; then
  printf 'FAIL: copy_iso_to_ventoy did not copy the downloaded ISO\n' >&2
  exit 1
fi

printf 'PASS: downloaded ISOs are detected and copied to Ventoy\n'

mkdir -p "$TEST_TMP/checklists"
copy_checklists "$TEST_TMP/checklists"
if ! grep -Fq "btrfs-progs v7.0 minimum" "$TEST_TMP/checklists/GPARTED-CHECKLIST.txt"; then
  printf 'FAIL: GParted checklist does not require a fs-verity-aware btrfs-progs\n' >&2
  exit 1
fi

printf 'PASS: GParted checklist requires btrfs-progs v7.0 or newer\n'
