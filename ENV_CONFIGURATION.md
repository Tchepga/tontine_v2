# Configuration du fichier .env - Socket.IO

## ⚠️ IMPORTANT : Configuration Socket.IO

Votre fichier `.env` doit contenir l'URL du serveur Socket.IO avec le protocole `ws://` ou `wss://`.
**Note** : Le service convertira automatiquement `ws://` en `http://` et `wss://` en `https://` pour Socket.IO.

## ✅ Configuration CORRECTE

```env
# URL de l'API pour les requêtes HTTP
API_URL=https://api.tontine.devcoorp.net

# URL pour les connexions Socket.IO
# Utilisez wss:// pour une connexion sécurisée (recommandé)
WS_URL=wss://api.tontine.devcoorp.net

# OU ws:// pour une connexion non sécurisée (non recommandé en production)
# WS_URL=ws://api.tontine.devcoorp.net
```

**Note** : Le service Socket.IO convertira automatiquement :
- `wss://` → `https://` (pour Socket.IO)
- `ws://` → `http://` (pour Socket.IO)

## ❌ Configurations INCORRECTES

```env
# MAUVAIS - Ne pas utiliser https:// pour WebSocket
WS_URL=https://api.tontine.devcoorp.net

# MAUVAIS - Ne pas inclure de port inutile
WS_URL=wss://api.tontine.devcoorp.net:0

# MAUVAIS - Ne pas utiliser http:// pour WebSocket
WS_URL=http://api.tontine.devcoorp.net
```

## 🔧 Configuration recommandée

```env
# Pour une connexion sécurisée (recommandé)
API_URL=https://api.tontine.devcoorp.net
WS_URL=wss://api.tontine.devcoorp.net
```

## 📝 Note sur les chemins WebSocket

Si votre serveur WebSocket utilise un chemin spécifique, ajoutez-le directement à l'URL :

```env
WS_URL=wss://api.tontine.devcoorp.net/ws
```

ou

```env
WS_URL=wss://api.tontine.devcoorp.net/socket
```

## 🧪 Tester après la correction

Après avoir corrigé le fichier `.env`, lancez :

```bash
flutter clean
flutter run
```

Ou utilisez l'écran de test intégré pour vérifier la connexion.

