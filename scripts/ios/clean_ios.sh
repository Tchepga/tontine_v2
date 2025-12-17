#!/bin/bash

# Script pour nettoyer les builds iOS et les fichiers dérivés
# Usage: ./scripts/ios/clean_ios.sh [--all]

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLEAN_ALL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            CLEAN_ALL=true
            shift
            ;;
        *)
            echo -e "${RED}Option inconnue: $1${NC}"
            echo "Usage: $0 [--all]"
            exit 1
            ;;
    esac
done

echo -e "${GREEN}=== Nettoyage des builds iOS ===${NC}"
echo ""

cd "$PROJECT_DIR"

# Nettoyer Flutter
echo -e "${YELLOW}Nettoyage Flutter...${NC}"
flutter clean

# Nettoyer les builds iOS
echo -e "${YELLOW}Suppression des builds iOS...${NC}"
rm -rf build/ios
rm -rf ios/build
rm -rf ios/DerivedData
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec

# Nettoyer Xcode
if [ "$CLEAN_ALL" = true ]; then
    echo -e "${YELLOW}Nettoyage complet Xcode...${NC}"
    rm -rf ~/Library/Developer/Xcode/DerivedData/*
    rm -rf ~/Library/Caches/com.apple.dt.Xcode/*
    echo -e "${GREEN}Cache Xcode nettoyé${NC}"
fi

# Nettoyer CocoaPods
if [ -f "ios/Podfile.lock" ]; then
    echo -e "${YELLOW}Suppression du lock CocoaPods...${NC}"
    rm -f ios/Podfile.lock
fi

# Réinstaller les pods si CocoaPods est disponible
if command -v pod &> /dev/null && [ "$CLEAN_ALL" = false ]; then
    echo -e "${YELLOW}Réinstallation des dépendances CocoaPods...${NC}"
    cd ios
    pod install
    cd ..
fi

echo ""
echo -e "${GREEN}=== Nettoyage terminé ===${NC}"
if [ "$CLEAN_ALL" = false ]; then
    echo -e "${YELLOW}Pour un nettoyage complet (incluant le cache Xcode), utilisez: $0 --all${NC}"
fi
