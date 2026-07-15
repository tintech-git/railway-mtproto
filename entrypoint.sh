#!/bin/bash
set -euo pipefail

LISTEN_PORT="${MTG_PORT:-8443}"
FAKE_DOMAIN="${MTG_FAKE_DOMAIN:-www.google.com}"

# MTG_SECRET can be supplied as a Railway environment variable; otherwise
# mtg generates a fresh FakeTLS secret for this domain on first boot.
# mtg v2 syntax: `generate-secret --hex <domain>` (no "tls"/"-c" flags,
# those were v1-only).
if [ -z "${MTG_SECRET:-}" ]; then
  MTG_SECRET="$(mtg generate-secret --hex "${FAKE_DOMAIN}")"
fi

# mtg v2 dropped the old `simple-run host:port secret` CLI form in favor
# of a TOML config file.
CONFIG_FILE="/tmp/mtg.toml"
cat > "${CONFIG_FILE}" <<EOF
secret = "${MTG_SECRET}"
bind-to = "0.0.0.0:${LISTEN_PORT}"
EOF

echo "==================================================="
echo " MTProto proxy starting"
echo " Listening on: 0.0.0.0:${LISTEN_PORT}"
echo " Secret: ${MTG_SECRET}"
echo " Fake domain: ${FAKE_DOMAIN}"
echo "==================================================="

exec mtg run "${CONFIG_FILE}"