---
name: deploy
description: >-
  Deploy Socrates Quiz to AWS Lightsail on a static IP (HTTPS) using
  deploy/lightsail Compose (Caddy + web + API + Postgres). Use when the user
  says /deploy, asks to publish to Lightsail, static IP, production preview,
  or launch.sh on the server.
disable-model-invocation: true
---

# Deploy (Lightsail static IP)

Canonical human doc: [`docs/deploy-lightsail.md`](../../../docs/deploy-lightsail.md).
Compose: [`deploy/lightsail/`](../../../deploy/lightsail/). ADR: [`docs/adr/0015-lightsail-production.md`](../../../docs/adr/0015-lightsail-production.md).

## Goal

Ship the **user-facing** stack so `https://<STATIC_IP>/` serves the SPA and `/v1/*` hits the Go API. Caddy obtains and renews a short-lived Let's Encrypt IP certificate.

## Non-goals

- Buying or configuring a custom domain
- Exposing `/api` (admin) on the public edge for IP preview
- Committing `.env` or real secrets

## Preconditions checklist

- [ ] Lightsail Ubuntu instance running (`ap-northeast-1` preferred)
- [ ] Static IP attached; firewall allows **TCP 22, 80, and 443**
- [ ] SSH as `ubuntu` works
- [ ] Repo available on the host under `~/quiz` (clone or sync)
- [ ] `deploy/lightsail/` present on the host (if missing from `git pull`, copy from this workspace or write files from that directory)

## Agent workflow

Copy this progress list and update it while working:

```text
Deploy progress:
- [ ] 1. Confirm AWS / instance / static IP
- [ ] 2. Docker CE ready (not conflicting docker.io)
- [ ] 3. deploy/lightsail + .env on host
- [ ] 4. launch.sh succeeds
- [ ] 5. healthz + SPA return 200
- [ ] 6. Published quizzes exist (or seed/publish)
- [ ] 7. Tell user the public URL
```

### 1. Instance

Prefer the user’s known static IP when they give one. Example from a prior session: `52.196.241.106` (do not assume it is still valid).

Never open 8080 or 5432 on the firewall.

### 2. Docker on the host

If `https://download.docker.com/linux/ubuntu` is already a source, **do not** install Ubuntu `docker.io` (conflicts with `containerd.io`).

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin git
sudo usermod -aG docker "$USER"
# newgrp docker   OR re-SSH
docker version
docker compose version
```

### 3. App files on the host

```bash
cd ~/quiz/deploy/lightsail
# Ensure Caddyfile, docker-compose.yml, launch.sh match the repo’s deploy/lightsail/
cp -n .env.example .env
```

`.env` must set:

| Key | Rule |
| --- | --- |
| `PUBLIC_IP` | Lightsail **static / public** IPv4 (not `172.26…`) |
| `VITE_API_BASE_URL` | `https://${PUBLIC_IP}` (expanded by `launch.sh`) |
| `CORS_ALLOWED_ORIGINS` | same as above |
| `DB_PASSWORD` / `JWT_SECRET` / `ADMIN_PASSWORD` | not the `change-me-…` placeholders |

Generate secrets with `openssl rand -hex 16` / `32` when needed. Give the user a full pasteable `.env` when they ask.

If `deploy/` is not on GitHub yet, write `Caddyfile`, `docker-compose.yml`, `launch.sh`, and `.env` onto the host with heredocs from the workspace copies. Do not invent a different Compose layout.

### 4. Launch

```bash
cd ~/quiz/deploy/lightsail
chmod +x launch.sh
./launch.sh
```

`launch.sh` must only run Docker Compose (pull/up/build). If it runs `apt`, the file on the host is wrong — overwrite it from the repo.

First build can take several minutes.

### 5. Smoke checks

From the agent machine or the host:

```bash
curl -fsS https://<STATIC_IP>/healthz          # expect: ok
curl -fsS https://<STATIC_IP>/v1/sections
curl -fsS "https://<STATIC_IP>/v1/quizzes?limit=5"
```

SPA HTML should return HTTP 200 for `/`.

### 6. Empty catalog (“box is up, no content”)

Public API only returns `status = 'published'`. Fresh DB migrations often seed rows as `unpublished`, so `/v1/quizzes` is `[]` while the shell still looks fine.

On the host, after Compose is healthy:

```bash
cd ~/quiz/deploy/lightsail
docker compose exec -T db \
  psql -U "$DB_USER" -d "$DB_NAME" \
  -c "SELECT status, COUNT(*) FROM quizzes GROUP BY status;"
```

To publish all seed rows for a preview (explicit user OK required if data is production-sensitive):

```bash
docker compose exec -T db \
  psql -U "$DB_USER" -d "$DB_NAME" \
  -c "UPDATE quizzes SET status = 'published' WHERE status = 'unpublished';"
```

Then re-check `/v1/quizzes` and the browser.

Prefer admin `sync-production` when admin is available; IP preview Caddy **does not** expose `/api`.

### 7. User reply

Always include:

1. Public URL: `https://<STATIC_IP>/`
2. What passed (`healthz`, quiz count)
3. Next failure if any (`docker compose ps`, `docker compose logs --tail=100 api`)

## Update / redeploy

```bash
cd ~/quiz && git pull
cd deploy/lightsail && ./launch.sh
```

If `PUBLIC_IP` changed, edit `.env` and rebuild (web bakes `VITE_API_BASE_URL`).

## Domain (optional)

Do not buy or configure a domain unless the user asks. The static IP already uses HTTPS. Details are in `docs/deploy-lightsail.md`.

## Safety

- Never commit `.env`
- Never paste live production secrets into the repo
- Do not expose admin `/api` on the public IP preview unless the user explicitly requests it and secrets are rotated
