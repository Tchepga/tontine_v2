#!/bin/bash

# Script pour lancer l'application Flutter web avec Chrome en désactivant les restrictions de sécurité

echo "🚀 Lancement de l'application Flutter web avec Chrome (sécurité désactivée)..."

flutter run -d chrome \
  --web-port=8080 \
  --web-browser-flag="--disable-web-security" \
  --web-browser-flag="--disable-features=IsolateOrigins,site-per-process" \
  --web-browser-flag="--user-data-dir=/tmp/chrome-dev-test" \
  --web-browser-flag="--allow-running-insecure-content" \
  --web-browser-flag="--ignore-certificate-errors" \
  --web-browser-flag="--unsafely-treat-insecure-origin-as-secure=http://localhost:8080" \
  --web-browser-flag="--disable-site-isolation-trials" \
  --web-browser-flag="--disable-blink-features=AutomationControlled"

