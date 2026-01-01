#!/bin/bash

# Script pour construire la version de test iOS de Thoua
# Usage: ./scripts/ios/build_test.sh [--simulator] [--install]

# Ne pas arrêter sur les erreurs pour certaines commandes
set +e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_SIMULATOR=false
INSTALL_SIMULATOR=false
CLEAN_BUILD=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --simulator)
            BUILD_SIMULATOR=true
            shift
            ;;
        --install)
            INSTALL_SIMULATOR=true
            BUILD_SIMULATOR=true
            shift
            ;;
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        *)
            echo -e "${RED}Option inconnue: $1${NC}"
            echo "Usage: $0 [--simulator] [--install] [--clean]"
            exit 1
            ;;
    esac
done

echo -e "${GREEN}=== Build de la version de test iOS Thoua ===${NC}"
echo ""

# Vérifier que nous sommes dans le bon répertoire
cd "$PROJECT_DIR"

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Flutter n'est pas installé ou n'est pas dans le PATH${NC}"
    exit 1
fi

# Nettoyer les builds précédents si demandé
if [ "$CLEAN_BUILD" = true ]; then
    echo -e "${YELLOW}Nettoyage des builds précédents...${NC}"
    flutter clean
fi

# Installer les dépendances
echo -e "${YELLOW}Installation des dépendances...${NC}"
flutter pub get

# Aller dans le répertoire iOS et installer les pods
echo -e "${YELLOW}Installation des dépendances CocoaPods...${NC}"
cd ios
if command -v pod &> /dev/null; then
    pod install
else
    echo -e "${YELLOW}Pod n'est pas installé, utilisation de pod via bundle si disponible...${NC}"
    if [ -f "Podfile" ]; then
        bundle exec pod install 2>/dev/null || echo -e "${YELLOW}Bundle pod non disponible, continuons...${NC}"
    fi
fi
cd ..

# Préparer le projet Flutter (générer les fichiers nécessaires)
# Cette étape peut échouer mais ce n'est pas critique si on utilise directement xcodebuild
echo -e "${YELLOW}Préparation du projet Flutter...${NC}"
if [ "$BUILD_SIMULATOR" = true ]; then
    flutter build ios --config-only --simulator 2>&1 | grep -v "Application not configured for iOS" || true
else
    flutter build ios --config-only 2>&1 | grep -v "Application not configured for iOS" || true
fi

# Réactiver la gestion d'erreurs pour la suite
set -e

# Construire l'application avec le schéma Test
if [ "$BUILD_SIMULATOR" = true ]; then
    echo -e "${YELLOW}Construction pour simulateur iOS avec configuration Test...${NC}"
    
    # Vérifier que le workspace existe
    if [ ! -d "ios/Runner.xcworkspace" ]; then
        echo -e "${RED}Erreur: ios/Runner.xcworkspace n'existe pas${NC}"
        echo -e "${YELLOW}Assurez-vous d'avoir exécuté 'pod install' dans le répertoire ios${NC}"
        exit 1
    fi
    
    # Construire avec xcodebuild en utilisant le schéma Runner-Test
    cd ios
    echo -e "${YELLOW}Utilisation du schéma Runner-Test avec configuration Test...${NC}"
    
    # Construire avec xcodebuild
    xcodebuild \
        -workspace Runner.xcworkspace \
        -scheme Runner-Test \
        -configuration Test \
        -sdk iphonesimulator \
        -destination 'generic/platform=iOS Simulator' \
        build \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO 2>&1 | tee /tmp/xcodebuild.log
    
    BUILD_RESULT=$?
    
    if [ $BUILD_RESULT -ne 0 ]; then
        echo -e "${RED}Erreur lors du build xcodebuild${NC}"
        echo -e "${YELLOW}Vérifiez les logs ci-dessus pour plus de détails${NC}"
        cd ..
        exit 1
    fi
    
    cd ..
    
    # Copier l'app vers l'emplacement standard Flutter si nécessaire
    # Chercher l'app dans différents emplacements possibles
    APP_FOUND=false
    
    if [ -d "ios/build/Test-iphonesimulator/Runner.app" ]; then
        mkdir -p build/ios/iphonesimulator
        cp -R ios/build/Test-iphonesimulator/Runner.app build/ios/iphonesimulator/
        APP_FOUND=true
        echo -e "${GREEN}Application trouvée dans: ios/build/Test-iphonesimulator/Runner.app${NC}"
    elif [ -d "ios/build/Debug-iphonesimulator/Runner.app" ]; then
        mkdir -p build/ios/iphonesimulator
        cp -R ios/build/Debug-iphonesimulator/Runner.app build/ios/iphonesimulator/
        APP_FOUND=true
        echo -e "${GREEN}Application trouvée dans: ios/build/Debug-iphonesimulator/Runner.app${NC}"
    elif [ -d "build/ios/iphonesimulator/Runner.app" ]; then
        APP_FOUND=true
        echo -e "${GREEN}Application trouvée dans: build/ios/iphonesimulator/Runner.app${NC}"
    fi
    
    if [ "$APP_FOUND" = false ]; then
        echo -e "${YELLOW}Attention: L'application n'a pas été trouvée dans les emplacements attendus${NC}"
        echo -e "${YELLOW}Recherche dans ios/build...${NC}"
        find ios/build -name "Runner.app" -type d 2>/dev/null | head -5
    fi
    
    if [ "$INSTALL_SIMULATOR" = true ]; then
        echo -e "${YELLOW}Installation sur le simulateur...${NC}"
        "$SCRIPT_DIR/run_simulator.sh" --install
    fi
else
    echo -e "${YELLOW}Construction pour appareil iOS avec configuration Test...${NC}"
    
    # Vérifier que le workspace existe
    if [ ! -d "ios/Runner.xcworkspace" ]; then
        echo -e "${RED}Erreur: ios/Runner.xcworkspace n'existe pas${NC}"
        echo -e "${YELLOW}Assurez-vous d'avoir exécuté 'pod install' dans le répertoire ios${NC}"
        exit 1
    fi
    
    # Construire avec xcodebuild en utilisant le schéma Runner-Test
    cd ios
    echo -e "${YELLOW}Utilisation du schéma Runner-Test avec configuration Test...${NC}"
    
    xcodebuild \
        -workspace Runner.xcworkspace \
        -scheme Runner-Test \
        -configuration Test \
        -sdk iphoneos \
        build \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO 2>&1 | tee /tmp/xcodebuild.log
    
    BUILD_RESULT=$?
    
    if [ $BUILD_RESULT -ne 0 ]; then
        echo -e "${RED}Erreur lors du build xcodebuild${NC}"
        echo -e "${YELLOW}Vérifiez les logs ci-dessus pour plus de détails${NC}"
        cd ..
        exit 1
    fi
    
    cd ..
    
    # Copier l'app vers l'emplacement standard Flutter si nécessaire
    APP_FOUND=false
    
    if [ -d "ios/build/Test-iphoneos/Runner.app" ]; then
        mkdir -p build/ios/iphoneos
        cp -R ios/build/Test-iphoneos/Runner.app build/ios/iphoneos/
        APP_FOUND=true
        echo -e "${GREEN}Application trouvée dans: ios/build/Test-iphoneos/Runner.app${NC}"
    elif [ -d "ios/build/Release-iphoneos/Runner.app" ]; then
        mkdir -p build/ios/iphoneos
        cp -R ios/build/Release-iphoneos/Runner.app build/ios/iphoneos/
        APP_FOUND=true
        echo -e "${GREEN}Application trouvée dans: ios/build/Release-iphoneos/Runner.app${NC}"
    elif [ -d "build/ios/iphoneos/Runner.app" ]; then
        APP_FOUND=true
        echo -e "${GREEN}Application trouvée dans: build/ios/iphoneos/Runner.app${NC}"
    fi
    
    if [ "$APP_FOUND" = false ]; then
        echo -e "${YELLOW}Attention: L'application n'a pas été trouvée dans les emplacements attendus${NC}"
        echo -e "${YELLOW}Recherche dans ios/build...${NC}"
        find ios/build -name "Runner.app" -type d 2>/dev/null | head -5
    else
        echo -e "${GREEN}Build terminé !${NC}"
        echo -e "${GREEN}Le fichier .app se trouve dans: build/ios/iphoneos/Runner.app${NC}"
    fi
fi

echo ""
echo -e "${GREEN}=== Build terminé avec succès ===${NC}"
echo -e "${GREEN}Bundle ID: fr.devcoorp.thoua.test${NC}"
echo -e "${GREEN}Nom d'affichage: Thoua Test${NC}"
