#!/usr/bin/env bash
# Deploy Expo Mela (stallbooking → server: expomela) to the VPS.
#
# Usage:
#   ./deploy/deploy-vps.sh
#   ./deploy/deploy-vps.sh root@1.2.3.4
#   DEPLOY_HOST=1.2.3.4 ./deploy/deploy-vps.sh
#   npm run deploy
#
# Requires SSH access to the VPS (prefer SSH keys).
# Does not overwrite /opt/apps/expomela/.env on the server.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

APP_NAME="expomela"
DEPLOY_HOST="${DEPLOY_HOST:-162.35.175.150}"
DEPLOY_USER="${DEPLOY_USER:-root}"
REMOTE_APP="/opt/apps/${APP_NAME}"
REMOTE_COMPOSE="/opt/apps"
SSH_TARGET="${1:-${DEPLOY_USER}@${DEPLOY_HOST}}"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  sed -n '2,16p' "$0"
  exit 0
fi

echo "==> Ensuring remote directory..."
ssh "$SSH_TARGET" "mkdir -p ${REMOTE_APP}"

echo "==> Syncing to ${SSH_TARGET}:${REMOTE_APP} ..."
rsync -az --delete \
  --exclude node_modules \
  --exclude dist \
  --exclude .git \
  --exclude .cursor \
  --exclude .env \
  --exclude 'server/.env' \
  --exclude 'server/data' \
  --exclude 'client/dist' \
  --exclude 'client/node_modules' \
  --exclude 'server/node_modules' \
  ./ "${SSH_TARGET}:${REMOTE_APP}/"

echo "==> Building & restarting ${APP_NAME} on server ..."
# Keep .env on the server; do not overwrite secrets from local.
ssh "$SSH_TARGET" "test -f ${REMOTE_APP}/.env || echo 'WARN: missing ${REMOTE_APP}/.env' >&2"
ssh "$SSH_TARGET" "cd ${REMOTE_COMPOSE} && docker compose up -d --build ${APP_NAME}"

echo ""
echo "Deployed ${APP_NAME}"
echo "  URL: http://${SSH_TARGET#*@}:4102/"
