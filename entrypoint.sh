#!/bin/bash
set -euo pipefail

# NOTE: we deliberately do NOT use Railway's auto-injected $PORT here.
# That variable is meant for HTTP services; Railway's TCP Proxy feature
# instead targets a fixed container port that you choose yourself and
# pass to tcpProxyCreate as `applicationPort`. Keep this in sync with
# whatever the local panel passes as MTG_PORT (default below).
LISTEN_PORT="${MTG_PORT:-8443}"

# mtg's FakeTLS mode disguises the proxy as a real TLS site. This is
# the domain it impersonates; override with MTG_FAKE_DOMAIN if you like.
FAKE_DOMAIN="${MTG_FAKE_DOMAIN:-www.google.com}"

# MTG_SECRET can be supplied as a Railway environment variable so the
# local panel already knows the value up front. If it's not set, mtg
# generates a fresh FakeTLS secret for this domain on first boot.
if [ -z "${MTG_SECRET:-}" ]; then
  MTG_SECRET="$(mtg generate-secret tls -c "${FAKE_DOMAIN}")"
fi

echo "==================================================="
echo " MTProto proxy starting"
echo " Listening on: 0.0.0.0:${LISTEN_PORT}"
echo " Secret:       ${MTG_SECRET}"
echo " Fake domain:  ${FAKE_DOMAIN}"
echo "==================================================="

exec mtg simple-run "0.0.0.0:${LISTEN_PORT}" "${MTG_SECRET}"
