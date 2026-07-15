# railway-mtproto

A minimal MTProto (Telegram) proxy, packaged to run as a Railway service.
Built on top of the open-source [mtg](https://github.com/9seconds/mtg) proxy.

This repo is **not meant to be deployed by hand**. It's designed to be pulled
and deployed automatically by the companion `local-panel` app — see the main
project README for the full flow. You *can* deploy it manually too, the steps
below cover that.

## What it does

- Builds a small Docker image with the `mtg` binary
- On boot, generates (or reuses) a FakeTLS secret and starts the proxy
- Listens on a fixed internal port, `MTG_PORT` (default `8443`)

## Important: this needs Railway's TCP Proxy, not a Domain

Railway's regular "public domain" only forwards HTTP(S)/WebSocket traffic.
MTProto is raw TCP, so the service needs Railway's **TCP Proxy** feature
instead (Settings → Networking → "TCP Proxy" in the dashboard, or the
`tcpProxyCreate` mutation via the API, pointed at `applicationPort: 8443`
to match `MTG_PORT`). That gives you a `hostname.proxy.rlwy.net:PORT` pair
— that's the address/port you hand to Telegram clients, not the
`*.up.railway.app` domain (which only exists for HTTP services and won't
be created here).

The `local-panel` app calls this API automatically as part of deployment.

## Manual deploy (optional)

1. Push this repo to your own GitHub account.
2. In Railway: New Project → Deploy from GitHub repo → select this repo.
3. Railway detects the `Dockerfile` and builds it automatically.
4. In the service's Settings → Networking, enable **TCP Proxy** and point it
   at container port `8443` (or whatever you set `MTG_PORT` to).
5. Optionally set an `MTG_SECRET` environment variable if you want a
   predictable secret; otherwise one is generated on first boot (check the
   deploy logs).
6. Take the TCP Proxy's `hostname:port` and the secret, and build a
   connection link:
   ```
   tg://proxy?server=<hostname>&port=<port>&secret=<secret>
   ```

## Environment variables

| Variable         | Required | Description                                   |
|------------------|----------|------------------------------------------------|
| `MTG_PORT`       | no       | Internal port mtg listens on (default `8443`) |
| `MTG_SECRET`     | no       | Fixed FakeTLS secret; auto-generated if unset |
| `MTG_FAKE_DOMAIN`| no       | Domain mtg impersonates (default `www.google.com`) |
