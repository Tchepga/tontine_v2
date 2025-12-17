#!/bin/bash

# Script pour lancer l'application Thoua Test sur le simulateur iOS
# Usage: ./scripts/ios/run_simulator.sh [device-name] [--install] [--list]

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
INSTALL_APP=false
LIST_DEVICES=false
DEVICE_NAME=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --install)
            INSTALL_APP=true
            shift
            ;;
        --list)
            LIST_DEVICES=true
            shift
            ;;
        --device)
            DEVICE_NAME="$2"
            shift 2
            ;;
        *)
            if [ -z "$DEVICE_NAME" ]; then
                DEVICE_NAME="$1"
            fi
            shift
            ;;
    esac
done

echo -e "${GREEN}=== Gestion du simulateur iOS ===${NC}"
echo ""

# Vérifier que xcrun simctl est disponible
if ! command -v xcrun &> /dev/null || ! xcrun simctl list devices &> /dev/null; then
    echo -e "${RED}Erreur: xcrun simctl n'est pas disponible${NC}"
    echo ""
    echo -e "${YELLOW}Problème détecté: Les outils de simulateur iOS ne sont pas accessibles.${NC}"
    echo ""
    echo -e "${YELLOW}Solutions possibles:${NC}"
    echo "1. Vérifiez que Xcode est installé (pas seulement les Command Line Tools)"
    echo "2. Configurez xcode-select pour pointer vers Xcode:"
    echo "   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
    echo "3. Acceptez la licence Xcode:"
    echo "   sudo xcodebuild -license accept"
    echo ""
    
    # Vérifier si Xcode est installé
    XCODE_PATH=$(find /Applications -name "Xcode.app" -type d 2>/dev/null | head -1)
    if [ -z "$XCODE_PATH" ]; then
        # Essayer aussi avec des variantes du nom
        XCODE_PATH=$(ls -d /Applications/Xcode*.app 2>/dev/null | head -1)
    fi
    
    if [ -n "$XCODE_PATH" ]; then
        echo -e "${GREEN}Xcode trouvé à: $XCODE_PATH${NC}"
        echo ""
        echo -e "${YELLOW}Pour corriger, exécutez:${NC}"
        echo "sudo xcode-select --switch $XCODE_PATH/Contents/Developer"
        echo ""
        echo -e "${YELLOW}Puis acceptez la licence Xcode:${NC}"
        echo "sudo xcodebuild -license accept"
    else
        echo -e "${RED}Xcode n'est pas installé dans /Applications${NC}"
        echo ""
        echo -e "${YELLOW}Solutions:${NC}"
        echo "1. Installez Xcode depuis l'App Store"
        echo "2. Si Xcode est installé ailleurs, configurez-le avec:"
        echo "   sudo xcode-select --switch /chemin/vers/Xcode.app/Contents/Developer"
        echo ""
        echo -e "${YELLOW}Note: Les Command Line Tools seuls ne suffisent pas.${NC}"
        echo -e "${YELLOW}Xcode complet est requis pour utiliser les simulateurs iOS.${NC}"
    fi
    
    exit 1
fi

# Lister les simulateurs disponibles
if [ "$LIST_DEVICES" = true ] || [ -z "$DEVICE_NAME" ]; then
    echo -e "${BLUE}Simulateurs iOS disponibles:${NC}"
    echo ""
    xcrun simctl list devices available | grep -E "iPhone|iPad" | head -20 || {
        echo -e "${YELLOW}Aucun simulateur disponible trouvé${NC}"
        echo -e "${YELLOW}Créez un simulateur via Xcode > Window > Devices and Simulators${NC}"
    }
    echo ""
    
    if [ "$LIST_DEVICES" = true ]; then
        exit 0
    fi
fi

# Trouver un simulateur disponible
if [ -z "$DEVICE_NAME" ]; then
    echo -e "${YELLOW}Recherche d'un simulateur disponible...${NC}"
    DEVICE_LIST=$(xcrun simctl list devices available 2>/dev/null)
    
    if [ -z "$DEVICE_LIST" ]; then
        echo -e "${RED}Impossible de lister les simulateurs${NC}"
        echo -e "${YELLOW}Vérifiez que Xcode est correctement configuré${NC}"
        exit 1
    fi
    
    DEVICE_UDID=$(echo "$DEVICE_LIST" | grep -i "iphone" | head -1 | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' | head -1)
    
    if [ -z "$DEVICE_UDID" ]; then
        echo -e "${RED}Aucun simulateur disponible trouvé${NC}"
        echo -e "${YELLOW}Créez un simulateur via Xcode > Window > Devices and Simulators${NC}"
        exit 1
    fi
    
    DEVICE_NAME=$(echo "$DEVICE_LIST" | grep "$DEVICE_UDID" | sed 's/.*(\(.*\))/\1/' | xargs)
    echo -e "${GREEN}Simulateur sélectionné: $DEVICE_NAME${NC}"
else
    # Trouver l'UDID du simulateur par nom
    DEVICE_LIST=$(xcrun simctl list devices available 2>/dev/null)
    
    if [ -z "$DEVICE_LIST" ]; then
        echo -e "${RED}Impossible de lister les simulateurs${NC}"
        echo -e "${YELLOW}Vérifiez que Xcode est correctement configuré${NC}"
        exit 1
    fi
    
    DEVICE_UDID=$(echo "$DEVICE_LIST" | grep -i "$DEVICE_NAME" | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' | head -1)
    
    if [ -z "$DEVICE_UDID" ]; then
        echo -e "${RED}Simulateur '$DEVICE_NAME' non trouvé${NC}"
        exit 1
    fi
fi

# Vérifier si le simulateur est déjà démarré
BOOT_STATUS=$(xcrun simctl list devices | grep "$DEVICE_UDID" | grep -oE '\(Booted\)|\(Shutdown\)')
if [[ "$BOOT_STATUS" == *"Shutdown"* ]]; then
    echo -e "${YELLOW}Démarrage du simulateur $DEVICE_NAME...${NC}"
    xcrun simctl boot "$DEVICE_UDID" 2>/dev/null || echo -e "${YELLOW}Le simulateur est peut-être déjà en cours de démarrage${NC}"
    
    # Ouvrir Simulator.app
    open -a Simulator
    
    # Attendre que le simulateur soit prêt
    echo -e "${YELLOW}Attente du démarrage du simulateur...${NC}"
    sleep 5
else
    echo -e "${GREEN}Le simulateur est déjà démarré${NC}"
fi

# Installer l'application si demandé
if [ "$INSTALL_APP" = true ]; then
    cd "$PROJECT_DIR"
    
    # Vérifier que l'app est construite
    # Chercher dans plusieurs emplacements possibles
    APP_PATH=""
    
    # Emplacement standard Flutter
    if [ -d "build/ios/iphonesimulator/Runner.app" ]; then
        APP_PATH="build/ios/iphonesimulator/Runner.app"
    # Emplacement xcodebuild standard
    elif [ -d "ios/build/Debug-iphonesimulator/Runner.app" ]; then
        APP_PATH="ios/build/Debug-iphonesimulator/Runner.app"
    # Emplacement xcodebuild avec configuration Test
    elif [ -d "ios/build/Test-iphonesimulator/Runner.app" ]; then
        APP_PATH="ios/build/Test-iphonesimulator/Runner.app"
    fi
    
    if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
        echo -e "${YELLOW}L'application n'est pas construite. Construction en cours...${NC}"
        "$SCRIPT_DIR/build_test.sh" --simulator
        # Réessayer de trouver l'app
        if [ -d "build/ios/iphonesimulator/Runner.app" ]; then
            APP_PATH="build/ios/iphonesimulator/Runner.app"
        elif [ -d "ios/build/Test-iphonesimulator/Runner.app" ]; then
            APP_PATH="ios/build/Test-iphonesimulator/Runner.app"
        elif [ -d "ios/build/Debug-iphonesimulator/Runner.app" ]; then
            APP_PATH="ios/build/Debug-iphonesimulator/Runner.app"
        fi
    fi
    
    if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
        echo -e "${RED}Impossible de trouver l'application construite${NC}"
        echo -e "${YELLOW}Emplacements vérifiés:${NC}"
        echo -e "  - build/ios/iphonesimulator/Runner.app"
        echo -e "  - ios/build/Test-iphonesimulator/Runner.app"
        echo -e "  - ios/build/Debug-iphonesimulator/Runner.app"
        exit 1
    fi
    
    echo -e "${GREEN}Application trouvée: $APP_PATH${NC}"
    
    echo -e "${YELLOW}Installation de l'application sur le simulateur...${NC}"
    xcrun simctl install "$DEVICE_UDID" "$APP_PATH"
    
    # Obtenir le bundle identifier
    BUNDLE_ID="fr.devcoorp.thoua.test"
    
    echo -e "${YELLOW}Lancement de l'application...${NC}"
    xcrun simctl launch "$DEVICE_UDID" "$BUNDLE_ID"
    
    echo ""
    echo -e "${GREEN}=== Application lancée avec succès ===${NC}"
    echo -e "${GREEN}Simulateur: $DEVICE_NAME${NC}"
    echo -e "${GREEN}Bundle ID: $BUNDLE_ID${NC}"
else
    echo ""
    echo -e "${GREEN}=== Simulateur prêt ===${NC}"
    echo -e "${GREEN}Simulateur: $DEVICE_NAME${NC}"
    echo -e "${YELLOW}Pour installer l'application, utilisez: $0 --install${NC}"
fi
