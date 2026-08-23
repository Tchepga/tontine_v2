#!/usr/bin/env bash
# Smoke tests contre API locale (Docker MySQL + seed ronaldo).
# Prérequis : Docker Desktop démarré.
set -euo pipefail

API_ROOT="$(cd "$(dirname "$0")/../../tontine-api-v2" && pwd)"
MOBILE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Local integration (full) ==="
echo "API  : $API_ROOT"
echo "App  : $MOBILE_ROOT"

cd "$API_ROOT"
docker compose up -d mysql
for _ in $(seq 1 30); do
  docker compose exec -T mysql mysqladmin ping -h localhost -uroot -proot 2>/dev/null | grep -q alive && break
  sleep 2
done

# Dev : schéma auto + compte root (docker-compose)
export NODE_ENV=development
export DB_SYNCHRONIZE=true
export DB_USERNAME=root
export DB_PASSWORD=root

# Toujours redémarrer pour appliquer le code API + NODE_ENV=development (throttle login assoupli).
pkill -f "node dist/main" 2>/dev/null || true
if lsof -ti :8080 >/dev/null 2>&1; then
  lsof -ti :8080 | xargs kill -9 2>/dev/null || true
fi
sleep 2
echo "Démarrage API sur :8080 (NODE_ENV=development)..."
npm run start >/tmp/tontine-api-local.log 2>&1 &
API_PID=$!
for _ in $(seq 1 30); do
  curl -sf http://localhost:8080/api/health >/dev/null 2>&1 && break
  sleep 2
done
if ! curl -sf http://localhost:8080/api/health >/dev/null 2>&1; then
  echo "API non joignable — voir /tmp/tontine-api-local.log"
  kill "$API_PID" 2>/dev/null || true
  exit 1
fi
echo "API prête (pid $API_PID)"

npx ts-node -r tsconfig-paths/register src/seed-test-tontine.ts || true

cd "$MOBILE_ROOT"
if [[ ! -f .integration.env ]]; then
  cat > .integration.env <<'EOF'
INTEGRATION_API_URL=http://localhost:8080
INTEGRATION_USERNAME=ronaldo
INTEGRATION_PASSWORD=Tontine2026!
INTEGRATION_MODE=full
EOF
  echo "Créé .integration.env (local seed)"
fi

export INTEGRATION_MODE=full

flutter test test/integration/ --concurrency=1 --reporter=expanded

if [[ -n "${API_PID:-}" ]]; then
  kill "$API_PID" 2>/dev/null || true
fi
