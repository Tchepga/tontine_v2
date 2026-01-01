# Guide de configuration iOS - Thoua

Ce guide vous explique comment configurer et utiliser l'environnement iOS pour développer et tester l'application Thoua.

## Table des matières

1. [Prérequis](#prérequis)
2. [Configuration initiale](#configuration-initiale)
3. [Utilisation du simulateur iOS](#utilisation-du-simulateur-ios)
4. [Builds de test](#builds-de-test)
5. [Scripts automatisés](#scripts-automatisés)
6. [Utilisation avec Xcode](#utilisation-avec-xcode)
7. [Dépannage](#dépannage)

## Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- **macOS** (version récente recommandée)
- **Xcode complet** (dernière version depuis l'App Store)
  - ⚠️ **Important** : Les Command Line Tools seuls ne suffisent pas. Xcode complet est requis pour utiliser les simulateurs iOS.
- **Flutter SDK** (version 3.5.3 ou supérieure)
- **CocoaPods** :
  ```bash
  sudo gem install cocoapods
  ```

Vérifiez vos installations :
```bash
flutter doctor
xcodebuild -version
pod --version
```

### Vérifier la configuration Xcode

Vérifiez que `xcode-select` pointe vers Xcode et non vers les Command Line Tools :

```bash
xcode-select -p
```

Cela devrait afficher quelque chose comme :
```
/Applications/Xcode.app/Contents/Developer
```

Si cela affiche `/Library/Developer/CommandLineTools`, vous devez configurer Xcode :

```bash
# Trouver Xcode
ls -d /Applications/Xcode*.app

# Configurer xcode-select (remplacez le chemin si nécessaire)
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Accepter la licence Xcode
sudo xcodebuild -license accept
```

## Configuration initiale

### 0. Script de configuration automatique (recommandé)

Pour configurer automatiquement l'environnement iOS, utilisez le script fourni :

```bash
./scripts/ios/setup_ios.sh
```

Ce script va :
- Vérifier l'installation de Xcode
- Configurer `xcode-select` correctement
- Accepter la licence Xcode
- Installer CocoaPods si nécessaire
- Vérifier la configuration Flutter

### 1. Installation manuelle des dépendances

Si vous préférez configurer manuellement :

```bash
# Depuis la racine du projet
flutter pub get
cd ios
pod install
cd ..
```

### 2. Configuration des certificats

Pour tester sur un appareil physique, vous devez :
1. Ouvrir le projet dans Xcode : `open ios/Runner.xcworkspace`
2. Sélectionner votre équipe de développement dans les paramètres du projet
3. Configurer les certificats de signature dans "Signing & Capabilities"

Pour le simulateur, aucune configuration de certificat n'est nécessaire.

## Utilisation du simulateur iOS

### Lister les simulateurs disponibles

```bash
xcrun simctl list devices available
```

Ou utilisez le script fourni :
```bash
./scripts/ios/run_simulator.sh --list
```

### Lancer un simulateur spécifique

**Méthode 1 : Via Xcode**
1. Ouvrez Xcode
2. Menu : `Xcode > Open Developer Tool > Simulator`
3. Sélectionnez un appareil dans le menu `Device`

**Méthode 2 : Via ligne de commande**
```bash
# Lancer un iPhone 15 Pro
xcrun simctl boot "iPhone 15 Pro"

# Ouvrir l'application Simulator
open -a Simulator
```

**Méthode 3 : Via le script automatisé**
```bash
# Lancer le premier simulateur disponible
./scripts/ios/run_simulator.sh

# Lancer un simulateur spécifique
./scripts/ios/run_simulator.sh "iPhone 15"
```

### Installer et lancer l'application sur le simulateur

**Via Flutter (recommandé) :**
```bash
flutter run -d ios
```

**Via le script automatisé :**
```bash
./scripts/ios/run_simulator.sh --install
```

**Via Xcode :**
1. Ouvrez `ios/Runner.xcworkspace` dans Xcode
2. Sélectionnez un simulateur dans la barre d'outils
3. Cliquez sur le bouton "Run" (▶️) ou appuyez sur `Cmd + R`

## Builds de test

L'application Thoua dispose d'une configuration de test séparée qui permet d'installer la version de test en parallèle de la version de production.

### Caractéristiques de la version de test

- **Bundle Identifier** : `fr.devcoorp.thoua.test`
- **Nom d'affichage** : "Thoua Test"
- **Configuration** : Test (similaire à Debug mais avec bundle ID différent)

### Build pour simulateur

```bash
# Build simple
flutter build ios --debug --simulator

# Build avec le script automatisé
./scripts/ios/build_test.sh --simulator
```

### Build pour appareil physique

```bash
# Build simple
flutter build ios --debug

# Build avec le script automatisé
./scripts/ios/build_test.sh
```

### Build et installation automatique

```bash
./scripts/ios/build_test.sh --simulator --install
```

Cette commande va :
1. Nettoyer les builds précédents
2. Installer les dépendances
3. Construire l'application pour le simulateur
4. Lancer un simulateur
5. Installer et lancer l'application

## Scripts automatisés

Le projet inclut plusieurs scripts pour faciliter le développement iOS.

### `scripts/ios/build_test.sh`

Construit la version de test de l'application.

**Options :**
- `--simulator` : Construit pour le simulateur
- `--install` : Installe automatiquement sur le simulateur après le build
- `--clean` : Nettoie les builds précédents avant de construire

**Exemples :**
```bash
# Build pour appareil
./scripts/ios/build_test.sh

# Build pour simulateur
./scripts/ios/build_test.sh --simulator

# Build et installation automatique
./scripts/ios/build_test.sh --simulator --install

# Build avec nettoyage complet
./scripts/ios/build_test.sh --simulator --clean
```

**Note :** Ce script utilise le schéma Xcode "Runner-Test" qui configure automatiquement le bundle identifier `fr.devcoorp.thoua.test` et le nom d'affichage "Thoua Test".

### `scripts/ios/run_simulator.sh`

Gère le lancement du simulateur et l'installation de l'application.

**Options :**
- `--list` : Liste tous les simulateurs disponibles
- `--install` : Installe et lance l'application
- `--device <nom>` : Spécifie un simulateur particulier

**Exemples :**
```bash
# Lister les simulateurs
./scripts/ios/run_simulator.sh --list

# Lancer un simulateur
./scripts/ios/run_simulator.sh

# Lancer un simulateur spécifique
./scripts/ios/run_simulator.sh "iPhone 15 Pro"

# Installer et lancer l'application
./scripts/ios/run_simulator.sh --install
```

### `scripts/ios/clean_ios.sh`

Nettoie les builds iOS et les fichiers dérivés.

**Options :**
- `--all` : Nettoie également le cache Xcode système

**Exemples :**
```bash
# Nettoyage standard
./scripts/ios/clean_ios.sh

# Nettoyage complet (incluant cache Xcode)
./scripts/ios/clean_ios.sh --all
```

## Utilisation avec Xcode

### Ouvrir le projet

```bash
open ios/Runner.xcworkspace
```

⚠️ **Important** : Utilisez toujours le fichier `.xcworkspace` et non `.xcodeproj` pour ouvrir le projet dans Xcode.

### Schémas disponibles

Le projet contient deux schémas :

1. **Runner** : Version de production
   - Bundle ID : `fr.devcoorp.thoua`
   - Nom : "Thoua"
   - Configuration : Debug/Release/Profile

2. **Runner-Test** : Version de test
   - Bundle ID : `fr.devcoorp.thoua.test`
   - Nom : "Thoua Test"
   - Configuration : Test

### Sélectionner un schéma

1. Dans Xcode, cliquez sur le schéma actuel dans la barre d'outils
2. Sélectionnez "Runner-Test" pour la version de test
3. Ou "Runner" pour la version de production

### Configurations de build

Pour changer la configuration de build :
1. Sélectionnez le projet dans le navigateur
2. Allez dans "Info" > "Configurations"
3. Sélectionnez la configuration souhaitée (Debug, Release, Profile, Test)

### Build depuis Xcode

1. Sélectionnez le schéma "Runner-Test"
2. Choisissez un simulateur ou un appareil
3. Appuyez sur `Cmd + B` pour build ou `Cmd + R` pour run

## Dépannage

### Erreur : "xcrun: error: unable to find utility 'simctl'"

Cette erreur indique que `xcode-select` ne pointe pas vers Xcode complet.

**Solution rapide :**
```bash
./scripts/ios/setup_ios.sh
```

**Solution manuelle :**

1. Vérifiez que Xcode est installé :
   ```bash
   find /Applications -name "Xcode.app" -type d
   ```

2. Si Xcode est installé, configurez `xcode-select` :
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   ```

3. Acceptez la licence Xcode :
   ```bash
   sudo xcodebuild -license accept
   ```

4. Exécutez le premier lancement :
   ```bash
   sudo xcodebuild -runFirstLaunch
   ```

5. Vérifiez la configuration :
   ```bash
   xcode-select -p
   # Devrait afficher: /Applications/Xcode.app/Contents/Developer
   ```

6. Testez `simctl` :
   ```bash
   xcrun simctl list devices
   ```

**Note :** Les Command Line Tools (`/Library/Developer/CommandLineTools`) ne suffisent pas. Xcode complet est requis pour les simulateurs iOS.

### Erreur : "CocoaPods not installed"

**Solution rapide :**
```bash
./scripts/ios/setup_ios.sh
```

**Solution manuelle :**
```bash
sudo gem install cocoapods
```

Vérifiez l'installation :
```bash
pod --version
```

### Erreur : "No such module 'Flutter'"

```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
```

### Erreur : "Signing for Runner requires a development team"

1. Ouvrez `ios/Runner.xcworkspace` dans Xcode
2. Sélectionnez le projet "Runner"
3. Allez dans "Signing & Capabilities"
4. Sélectionnez votre équipe de développement

### Le simulateur ne démarre pas

```bash
# Vérifier les simulateurs disponibles
xcrun simctl list devices

# Redémarrer le service de simulateur
killall Simulator
open -a Simulator
```

### Erreur : "CocoaPods not installed"

```bash
sudo gem install cocoapods
cd ios
pod install
```

### L'application ne se lance pas sur le simulateur

1. Vérifiez que le simulateur est démarré
2. Nettoyez et reconstruisez :
   ```bash
   ./scripts/ios/clean_ios.sh
   flutter clean
   flutter pub get
   flutter run -d ios
   ```

### Problèmes de cache

```bash
# Nettoyage complet
./scripts/ios/clean_ios.sh --all
flutter clean
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Erreur de build : "Multiple commands produce"

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

### Le bundle identifier est incorrect

Vérifiez que vous utilisez le bon schéma :
- **Runner** → `fr.devcoorp.thoua`
- **Runner-Test** → `fr.devcoorp.thoua.test`

## Commandes utiles

### Flutter

```bash
# Lancer sur simulateur
flutter run -d ios

# Build pour simulateur
flutter build ios --debug --simulator

# Build pour appareil
flutter build ios --debug

# Lister les appareils
flutter devices
```

### Simulateur

```bash
# Lister les simulateurs
xcrun simctl list devices

# Démarrer un simulateur
xcrun simctl boot <device-id>

# Installer une app
xcrun simctl install <device-id> <path-to-app>

# Lancer une app
xcrun simctl launch <device-id> <bundle-id>

# Prendre une capture d'écran
xcrun simctl io booted screenshot screenshot.png

# Réinitialiser un simulateur
xcrun simctl erase <device-id>
```

### Xcode

```bash
# Ouvrir le projet
open ios/Runner.xcworkspace

# Build depuis la ligne de commande
xcodebuild -workspace ios/Runner.xcworkspace \
           -scheme Runner-Test \
           -configuration Test \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Ressources supplémentaires

- [Documentation Flutter iOS](https://docs.flutter.dev/deployment/ios)
- [Guide Xcode](https://developer.apple.com/xcode/)
- [Documentation CocoaPods](https://guides.cocoapods.org/)

## Support

Pour toute question ou problème, consultez :
- Le fichier `README.md` du projet
- Les logs Flutter : `flutter logs`
- Les logs Xcode : Console.app > Simulator
