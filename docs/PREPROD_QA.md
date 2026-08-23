# Checklist soft launch — Thoua (préprod iOS / Android)

> Dernière mise à jour : audit production P0–P2. Cocher chaque item avant promotion stores.

## Prérequis stores

- [ ] Compte Apple Developer + App Store Connect (bundle `fr.devcoorp.thoua`)
- [ ] Compte Google Play Console (package `fr.devcoorp.tontine_v2`)
- [ ] Keystore Android configuré dans Codemagic (`tontine_keystore`) — **pas** de fallback debug
- [ ] Certificats / provisioning iOS via Codemagic
- [ ] Remplacer `APP_DOWNLOAD_LINK_IOS` (id `000000000`) par l’URL App Store réelle dans `assets/env/.env.production`
- [ ] Renseigner `SENTRY_DSN` dans Codemagic (`basic-env`) **et** `--dart-define=SENTRY_DSN=…`
- [ ] Renseigner `SENTRY_DSN` côté API VPS (`~/config/.env-tontine-api`)
- [ ] Ajouter `ios/GoogleService-Info.plist` + `android/app/google-services.json` pour le push FCM (fichiers gitignorés)
- [ ] Confirmer que `https://api.tontine.devcoorp.net` est bien l’API de production métier
- [ ] Migrations DB exécutées en prod (`npm run migration:run:prod`)

## Builds CI

```bash
# Staging (branche develop) → APK + IPA ad hoc
# Codemagic workflow: testers-distribution (--dart-define=ENV=staging)
# ⚠️ Idéalement pointer staging vers une API dédiée (pas prod)

# Production interne (branche master)
# Codemagic: android-deploy → Play internal
# Codemagic: ios-deploy → TestFlight
```

## QA manuelle — Auth & sécurité

- [ ] Login / logout username + mot de passe
- [ ] Session expirée (401) → redirection login automatique
- [ ] Création membre → dialogue mot de passe aléatoire (plus de `changeme` en prod)
- [ ] Force change password si API renvoie `mustChangePassword: true`
- [ ] Change password (compte connecté)
- [ ] Forgot / reset password (si Resend configuré)
- [ ] Utilisateur A ne voit **pas** les tontines / données de l’utilisateur B
- [ ] Header `tontine-id` envoyé (vérifier via logs API si besoin)
- [ ] WebSocket refuse connexion sans token valide

## QA manuelle — Cotisations / cashflow

- [ ] Créer versement montant entier > 0
- [ ] Rejeter `12,5` / montant vide / négatif
- [ ] Double-tap « Enregistrer » → un seul dépôt
- [ ] Dépôt PENDING ne modifie **pas** le cashflow total

## QA manuelle — Membres & sanctions

- [ ] Ajouter un membre (président)
- [ ] Modifier les rôles bureau
- [ ] Retirer un membre
- [ ] Créer / modifier / supprimer une sanction

## QA manuelle — Rapports & événements

- [ ] Créer un rapport de réunion avec pièce jointe
- [ ] Télécharger la pièce jointe
- [ ] Créer / modifier / supprimer un événement
- [ ] Ajouter / retirer un participant

## QA manuelle — Cycle tontine (clôture / redémarrage)

- [ ] Président peut clôturer une tontine ACTIVE
- [ ] Tontine CLOSED : bandeau « consultation seule », pas de création dépôt/événement/prêt
- [ ] Récapitulatif clôture : reliquat + part par membre visible
- [ ] Redémarrer une tontine clôturée avec report du reliquat en caisse
- [ ] Redémarrer sans report du reliquat (caisse à 0)
- [ ] Nouvelle tontine : membres et rôles copiés, lien vers tontine parente
- [ ] Tontine clôturée reste consultable dans la liste (badge « Clôturée »)
- [ ] Changement de tontine : pas de données stale (événements/prêts/notifs de l’ancienne)

## QA manuelle — Multi-tontines

- [ ] Créer plusieurs tontines
- [ ] Basculer entre tontines sans crash
- [ ] Données isolées par tontine après switch

## QA manuelle — Prêts

- [ ] Création prêt avec montant valide
- [ ] Validation président
- [ ] Impossible sur tontine CLOSED

## QA manuelle — Temps réel

- [ ] WebSocket / notifs locales app ouverte
- [ ] Push distant (si Firebase configuré) app en arrière-plan

## QA manuelle — Réseau

- [ ] Mode avion → écran connexion / retry
- [ ] HTTPS uniquement (pas de cleartext)

## QA manuelle — Branding

- [ ] Nom affiché **Thoua** sur Android et iOS
- [ ] Icônes / splash corrects

## Promotion production

- [ ] QA interne OK (checklist ci-dessus)
- [ ] Pas de crash Sentry bloquants (mobile + API)
- [ ] Runbook API lu et backup DB testé ([RUNBOOK_PRODUCTION.md](../../tontine-api-v2/docs/RUNBOOK_PRODUCTION.md))
- [ ] Décision inscription publique validée (register ouvert vs invitation only)
- [ ] Play : internal → closed/open → production
- [ ] App Store : TestFlight → Submit for Review
