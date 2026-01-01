# Thoua - Application Tontine

Application Flutter pour la gestion de tontines.

## Getting Started

This project is a starting point for a Flutter application that follows the
[simple app state management
tutorial](https://flutter.dev/to/state-management-sample).

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Prérequis

- Flutter SDK (version 3.5.3 ou supérieure)
- Dart SDK
- Xcode (pour iOS)
- Android Studio / Android SDK (pour Android)

## Installation

```bash
# Cloner le projet
git clone <repository-url>
cd tontine_v2

# Installer les dépendances
flutter pub get

# Pour iOS, installer les pods
cd ios
pod install
cd ..
```

## Développement

### Lancer l'application

```bash
# Lancer sur un appareil connecté ou simulateur
flutter run

# Lancer sur un appareil spécifique
flutter run -d <device-id>

# Lister les appareils disponibles
flutter devices
```

## iOS

### Configuration initiale

**Script de configuration automatique (recommandé) :**
```bash
./scripts/ios/setup_ios.sh
```

Ce script configure automatiquement Xcode, CocoaPods et vérifie votre environnement.

### Versions disponibles

L'application Thoua supporte deux versions :
- **Production** : Bundle ID `fr.devcoorp.thoua` - Nom "Thoua"
- **Test** : Bundle ID `fr.devcoorp.thoua.test` - Nom "Thoua Test"

### Développement sur simulateur iOS

**Méthode rapide :**
```bash
# Lancer sur simulateur iOS
flutter run -d ios

# Build et installation automatique de la version de test
./scripts/ios/build_test.sh --simulator --install
```

**Scripts disponibles :**
- `./scripts/ios/build_test.sh` - Construire la version de test
- `./scripts/ios/run_simulator.sh` - Gérer le simulateur iOS
- `./scripts/ios/clean_ios.sh` - Nettoyer les builds iOS

**Exemples :**
```bash
# Lister les simulateurs disponibles
./scripts/ios/run_simulator.sh --list

# Lancer un simulateur et installer l'app
./scripts/ios/run_simulator.sh --install

# Build pour simulateur
./scripts/ios/build_test.sh --simulator
```

### Utilisation avec Xcode

1. Ouvrir le projet :
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Sélectionner le schéma :
   - **Runner** : Version de production
   - **Runner-Test** : Version de test

3. Choisir un simulateur ou un appareil et lancer (⌘R)

### Documentation complète

Pour plus de détails sur la configuration iOS, consultez la [documentation complète iOS](docs/IOS_SETUP.md).

## Android

### Build de test

```bash
# Build debug
flutter build apk --debug

# Build release
flutter build apk --release
```

## Assets

The `assets` directory houses images, fonts, and any other files you want to
include with your application.

The `assets/images` directory contains [resolution-aware
images](https://flutter.dev/to/resolution-aware-images).

## Localization

This project generates localized messages based on arb files found in
the `lib/src/localization` directory.

To support additional languages, please visit the tutorial on
[Internationalizing Flutter apps](https://flutter.dev/to/internationalization).

## Structure du projet

```
lib/
  src/
    providers/      # Providers pour la gestion d'état
    screen/         # Écrans de l'application
    services/       # Services (API, notifications, etc.)
    widgets/        # Widgets réutilisables
    theme/          # Thème de l'application
scripts/
  ios/              # Scripts d'automatisation iOS
docs/               # Documentation
```

## Scripts utiles

### iOS
- `scripts/ios/build_test.sh` - Build de la version de test
- `scripts/ios/run_simulator.sh` - Gestion du simulateur
- `scripts/ios/clean_ios.sh` - Nettoyage des builds

## Ressources

- [Documentation Flutter](https://docs.flutter.dev)
- [Documentation iOS](docs/IOS_SETUP.md)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
