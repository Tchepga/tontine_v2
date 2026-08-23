#!/usr/bin/env bash
# Tests d'intégration mobile ↔ API live
# Usage: ./tool/run_integration_tests.sh [smoke|full]
# Depuis n'importe où : /Users/patricktchepga/projet/tontine_v2/tool/run_integration_tests.sh smoke
set -euo pipefail

MODE="${1:-smoke}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f pubspec.yaml ]]; then
  echo "Erreur: pubspec.yaml introuvable dans $ROOT"
  echo "Ce script doit être dans tontine_v2/tool/ — pas besoin de « cd tontine_v2 » si vous l'appelez par chemin complet."
  exit 1
fi

if [[ -f "$ROOT/.integration.env" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$ROOT/.integration.env"
  set +a
  echo "Config chargée depuis $ROOT/.integration.env"
fi

if [[ -z "${INTEGRATION_API_URL:-}" ]]; then
  echo "INTEGRATION_API_URL non défini."
  echo ""
  echo "Exemple (depuis votre compte Thoua sur l'API prod) :"
  echo "  export INTEGRATION_API_URL=https://api.tontine.devcoorp.net"
  echo "  export INTEGRATION_USERNAME=votre_identifiant"
  echo "  export INTEGRATION_PASSWORD='votre_mot_de_passe'"
  echo "  # ou : cp .integration.env.example .integration.env"
  echo "  $ROOT/tool/run_integration_tests.sh smoke"
  exit 1
fi

if [[ -z "${INTEGRATION_PASSWORD:-}" ]]; then
  echo "INTEGRATION_PASSWORD non défini."
  echo "Le mot de passe seed (Tontine2026!) ne fonctionne que si ce compte existe sur l'API cible."
  echo "Utilisez les identifiants avec lesquels vous vous connectez dans l'app mobile."
  echo "Ou copiez .integration.env.example → .integration.env à la racine du projet."
  exit 1
fi

export INTEGRATION_MODE="$MODE"

echo "=== Integration tests ($MODE) ==="
echo "Répertoire : $ROOT"
echo "API        : $INTEGRATION_API_URL"
echo "User       : ${INTEGRATION_USERNAME:-ronaldo}"
echo ""

if [[ "$MODE" == "full" ]]; then
  flutter test test/integration/ --reporter=expanded
else
  flutter test test/integration/smoke_integration_test.dart \
    test/integration/mobile_contract_integration_test.dart \
    --reporter=expanded
fi
