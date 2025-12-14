#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE_DIR="$ROOT_DIR/Tests/Fixtures"
SPEC_FILE="$FIXTURE_DIR/samples.json"

if [ ! -f "$SPEC_FILE" ]; then
  echo "Missing $SPEC_FILE. Copy samples.json.template to samples.json and fill url/sha256." >&2
  exit 1
fi

mkdir -p "$FIXTURE_DIR"

hash_cmd() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

python3 - <<'PY' "$SPEC_FILE" "$FIXTURE_DIR"
import json, sys, pathlib, subprocess
spec_path = pathlib.Path(sys.argv[1])
dest_dir = pathlib.Path(sys.argv[2])
spec = json.loads(spec_path.read_text())
for entry in spec:
    name = entry["name"]
    url = entry["url"]
    dest = dest_dir / name
    print(f"Downloading {name} ...")
    subprocess.run(["curl", "-L", "-o", str(dest), url], check=True)
PY

while IFS= read -r line; do
  name=$(echo "$line" | awk '{print $1}')
  url=$(echo "$line" | awk '{print $2}')
  sha=$(echo "$line" | awk '{print $3}')
  [ -z "$name" ] && continue
  file="$FIXTURE_DIR/$name"
  if [ ! -f "$file" ]; then
    echo "Missing downloaded file $file" >&2
    exit 2
  fi
  actual=$(hash_cmd "$file")
  if [[ "$actual" != "$sha" ]]; then
    echo "SHA mismatch for $name (expected $sha, got $actual)" >&2
    exit 3
  fi
done < <(python3 - <<'PY' "$SPEC_FILE"
import json, sys
spec = json.loads(open(sys.argv[1]).read())
for entry in spec:
    print(entry["name"], entry["url"], entry["sha256"])
PY)

echo "Fixtures downloaded and verified."
