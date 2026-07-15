# MTProto proxy for Railway
# Based on the open-source "mtg" proxy: https://github.com/9seconds/mtg
FROM nineseconds/mtg:2 AS mtg

FROM alpine:3.20
RUN apk add --no-cache bash openssl ca-certificates
COPY --from=mtg /mtg /usr/local/bin/mtg
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Fixed internal port the proxy listens on. Railway's TCP Proxy feature
# is pointed at this exact port (see local-panel, which sets it and
# passes the same value as applicationPort to tcpProxyCreate).
ENV MTG_PORT=8443

ENTRYPOINT ["/entrypoint.sh"]
