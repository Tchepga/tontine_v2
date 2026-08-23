# Tests d'intégration — Thoua (mobile ↔ API)

Suite HTTP qui vérifie que **les fonctionnalités critiques** répondent correctement sur une API **réelle** (local, staging ou prod).

> Ce ne sont **pas** des tests UI Flutter (pas d’émulateur). Ils reproduisent exactement ce que font `tontine_service.dart` et `event_service.dart`.

---

## Deux modes

| Mode | Variable | Comportement | Environnement |
|---|---|---|---|
| **smoke** (défaut) | `INTEGRATION_MODE=smoke` | Lecture seule : login, listes, pagination | OK **prod** |
| **full** | `INTEGRATION_MODE=full` | Crée puis supprime event, dépôt, membre | **Staging** uniquement |

---

## Fonctionnalités couvertes

### Smoke (lecture seule)

| Feature | Endpoint testé |
|---|---|
| Santé API | `GET /api/health` |
| Auth login | `POST /api/auth/login` |
| Détail tontine | `GET /api/tontine/:id` |
| Mouvements paginés | `GET /api/tontine/:id/deposit?page=1&limit=5` |
| Événements (liste) | `GET /api/event/tontine/:id` |
| Parts par membre | `GET /api/tontine/:id/members/contributions` |
| Prêts | `GET /api/loan` |
| Notifications | `GET /api/notification/tontine/:id` |
| Rapports | `GET /api/tontine/:id/rapport` |

### Full (écriture + cleanup)

| Feature | Scénario | Fichier test |
|---|---|---|
| **Créer un événement** | Payload `CreateEventDto` + header `tontine-id` | `mobile_contract_integration_test.dart` |
| **Header manquant** | POST /event sans `tontine-id` → 403 | `mobile_contract_integration_test.dart` |
| **Créer un versement** | Payload `CreateDepositDto` (memberId, PENDING, VERSEMENT) | `mobile_contract_integration_test.dart` |
| **Ajouter un membre** | POST /member + PATCH attach (comme `addMemberToTontine`) | `mobile_contract_integration_test.dart` |

Les payloads sont centralisés dans `test/integration/mobile_payloads.dart` (miroir des DTO mobile).

### Tests unitaires contrat (sans API)

`test/integration/mobile_payloads_test.dart` — vérifie la forme JSON en CI à chaque run.

---

## Exécution locale

### Prérequis

- Compte test sur l’API (seed : `ronaldo` / `Tontine2026!`)
- Au moins une tontine associée au compte

### Fichier `.integration.env` (recommandé en local)

À la racine de `tontine_v2`, copiez le modèle puis renseignez vos identifiants :

```bash
cp .integration.env.example .integration.env
# éditer .integration.env — fichier gitignored
```

Le script `tool/run_integration_tests.sh` source ce fichier s'il existe. Les tests Dart le chargent aussi au démarrage ; les variables déjà exportées dans le shell **priment** sur le fichier.

### Smoke sur prod

```bash
# Option A — fichier local (voir ci-dessus)
/Users/patricktchepga/projet/tontine_v2/tool/run_integration_tests.sh smoke

# Option B — exports shell
export INTEGRATION_API_URL=https://api.tontine.devcoorp.net
export INTEGRATION_USERNAME=votre_identifiant   # compte réel sur cette API
export INTEGRATION_PASSWORD='votre_mot_de_passe'  # obligatoire

/Users/patricktchepga/projet/tontine_v2/tool/run_integration_tests.sh smoke
```

> **Important** : le compte seed `ronaldo` / `Tontine2026!` n'existe que si vous avez lancé le seed SQL sur **cette** base. En prod, utilisez **vos identifiants app** (ex. le compte avec lequel vous testez sur le téléphone).

### Smoke en local (Docker + seed automatique)

Sans toucher à la prod — Docker Desktop requis. Lance **toute** la suite (smoke + full + contrats) :

```bash
/Users/patricktchepga/projet/tontine_v2/tool/run_local_integration.sh
```

Démarre MySQL, l’API en mode dev (`:8080`), seed `ronaldo`, `INTEGRATION_MODE=full`, puis les 19 tests d’intégration.

### Alternative manuelle

```bash
cd /Users/patricktchepga/projet/tontine_v2
export INTEGRATION_API_URL=...
export INTEGRATION_USERNAME=...
export INTEGRATION_PASSWORD=...
flutter test test/integration/smoke_integration_test.dart --reporter=expanded
```

### Full sur staging (recommandé)

```bash
export INTEGRATION_API_URL=https://api-staging.tontine.devcoorp.net
export INTEGRATION_MODE=full
# optionnel : INTEGRATION_TONTINE_ID=42

flutter test test/integration/ --reporter=expanded
```

### Script raccourci

```bash
./tool/run_integration_tests.sh smoke   # prod-safe
./tool/run_integration_tests.sh full    # staging
```

---

## CI / déploiement

### GitHub Actions (`deploy.yml`)

Job `integration-smoke` après les tests unitaires :
- S’exécute si le secret `INTEGRATION_API_URL` est défini
- Mode smoke uniquement (pas d’écriture)

### Codemagic (`codemagic.yaml`)

Étape optionnelle dans `android-deploy` après `flutter test` :
- Variables dans le groupe `basic-env` : `INTEGRATION_API_URL`, `INTEGRATION_USERNAME`, `INTEGRATION_PASSWORD`

---

## Variables d'environnement

| Variable | Obligatoire | Description |
|---|---|---|
| `INTEGRATION_API_URL` | Oui | URL sans `/api` (ex. `https://api.tontine.devcoorp.net`) |
| `INTEGRATION_USERNAME` | Non | Pas de défaut utile — votre login app |
| `INTEGRATION_PASSWORD` | **Oui** | Mot de passe du compte sur l'API cible |
| `INTEGRATION_TONTINE_ID` | Non | Auto : première tontine du user |
| `INTEGRATION_MODE` | Non | `smoke` ou `full` |

Source : exports shell, CI, ou `.integration.env` (voir `.integration.env.example`). Shell > fichier.

---

## Quand un test échoue

| Symptôme | Cause probable |
|---|---|
| Login 401 | Mauvais user/password pour **cette** API — utilisez vos identifiants app, pas le seed local |
| Event create 403 | Header `tontine-id` manquant ou rôle insuffisant |
| Deposits 200 mais pas `{items}` | API pas à jour (ancienne version sans pagination) |
| Contributions 403 | User test n’est pas président/trésorier |
| Tests skipped | `INTEGRATION_API_URL` ou `INTEGRATION_PASSWORD` manquant (shell ou `.integration.env`) |

---

## Roadmap

- [ ] UI `integration_test` (Patrol / flutter driver) pour parcours écran login → cashflow
- [ ] API e2e in-process avec MySQL Docker en CI
- [ ] Environnement staging dédié automatiquement seedé
