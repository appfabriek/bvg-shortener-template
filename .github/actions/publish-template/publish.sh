#!/usr/bin/env bash
set -euo pipefail

: "${BVG_HOST:?}"
: "${BVG_TOKEN:?}"

PROTOCOL="${BVG_PROTOCOL:-https}"
export BVG_PATHS="${BVG_PATHS:-css/**/*,js/**/*,images/**/*,fonts/**/*,**/*.html,manifest.json,browserconfig.xml,llms.txt,sitemap.xml,robots.txt}"

python3 - <<'PY' > /tmp/bvg-template-payload.json
import base64, glob, json, os
from pathlib import Path

TEXT_EXT = {".html", ".css", ".js", ".json", ".xml", ".txt", ".map", ".svg"}
patterns = [p.strip() for p in os.environ.get("BVG_PATHS", "").split(",") if p.strip()]
paths = []
for pattern in patterns:
    matched = glob.glob(pattern, recursive=True)
    if not matched and Path(pattern).is_file():
        matched = [pattern]
    paths.extend(matched)

files = []
seen = set()
for path in sorted(set(paths)):
    p = Path(path)
    if not p.is_file():
        continue
    key = str(p).replace("\\", "/").lstrip("./")
    if key in seen or ".." in key.split("/"):
        continue
    seen.add(key)
    raw = p.read_bytes()
    ext = p.suffix.lower()
    if ext in TEXT_EXT or p.name.lower() in {"llms.txt", "manifest.json", "browserconfig.xml"}:
        try:
            content = raw.decode("utf-8")
            encoding = "utf-8"
        except UnicodeDecodeError:
            content = base64.b64encode(raw).decode("ascii")
            encoding = "base64"
    else:
        content = base64.b64encode(raw).decode("ascii")
        encoding = "base64"
    files.append({"path": key, "content": content, "encoding": encoding})

if not files:
    raise SystemExit(f"No template files matched: {patterns}")

payload = {
    "files": files,
    "sha": os.environ.get("BVG_SHA") or None,
    "repo": os.environ.get("BVG_REPO") or None,
    "branch": os.environ.get("BVG_BRANCH") or None,
}
print(json.dumps(payload))
print(f"Prepared {len(files)} file(s)", file=__import__("sys").stderr)
for f in files:
    print(f" - {f['path']} ({f['encoding']})", file=__import__("sys").stderr)
PY

url="${PROTOCOL}://${BVG_HOST}/api/v1/template/publish"
echo "Publishing template to ${url}"

tmp="$(mktemp)"
code="$(curl -sS -o "$tmp" -w "%{http_code}" \
  -X POST "$url" \
  -H "Authorization: Bearer ${BVG_TOKEN}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  --data @"/tmp/bvg-template-payload.json")"

cat "$tmp"
echo
if [[ "$code" != "200" ]]; then
  echo "Publish failed with HTTP $code" >&2
  exit 1
fi
