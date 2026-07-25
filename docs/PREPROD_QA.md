# Checklist soft launch — Thoua (préprod iOS / Android)

## Prérequis stores

- [ ] Compte Apple Developer + App Store Connect (bundle `fr.devcoorp.thoua`)
- [ ] Compte Google Play Console (package `fr.devcoorp.tontine_v2`)
- [ ] Keystore Android configuré dans Codemagic (`tontine_keystore`) — **pas** de fallback debug
- [ ] Certificats / provisioning iOS via Codemagic
- [ ] Remplacer `APP_DOWNLOAD_LINK_IOS` (id `000000000`) par l’URL App Store réelle dans `assets/env/.env.production`
- [ ] Renseigner `SENTRY_DSN` (env ou `--dart-define=SENTRY_DSN=…`)
- [ ] Ajouter `ios/GoogleService-Info.plist` + `android/app/google-services.json` pour le push FCM (fichiers gitignorés)
- [ ] Confirmer que `https://api.tontine.devcoorp.net` est bien l’API de production métier

## Builds CI

```bash
# Staging (branche develop) → APK + IPA ad hoc
# Codemagic workflow: testers-distribution (--dart-define=ENV=staging)

# Production interne (branche master)
# Codemagic: android-deploy → Play internal
# Codemagic: ios-deploy → TestFlight
```

## QA manuelle (TestFlight + Play internal)

1. **Auth**
   - [ ] Login / logout
   - [ ] Session expirée (401) → redirection login
   - [ ] Création membre → dialogue mot de passe aléatoire (plus de `changeme`)
   - [ ] Force change password si API renvoie `mustChangePassword`

2. **Cotisations / cashflow**
   - [ ] Créer versement montant entier > 0
   - [ ] Rejeter `12,5` / montant vide / négatif
   - [ ] Double-tap « Enregistrer » → un seul dépôt

3. **Prêts / enchères**
   - [ ] Création prêt avec montant valide
   - [ ] Validation président

4. **Temps réel**
   - [ ] WebSocket / notifs locales app ouverte
   - [ ] Push distant (si Firebase configuré) app en arrière-plan

5. **Réseau**
   - [ ] Mode avion → écran connexion / retry
   - [ ] HTTPS uniquement (pas de cleartext)

6. **Branding**
   - [ ] Nom affiché **Thoua** sur Android et iOS
   - [ ] Icônes / splash corrects

## Promotion production

- [ ] QA interne OK (checklist ci-dessus)
- [ ] Pas de crash Sentry bloquants
- [ ] Play : internal → closed/open → production
- [ ] App Store : TestFlight → Submit for Review
