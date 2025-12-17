#!/bin/bash

# Script pour configurer l'environnement iOS pour Thoua
# Usage: ./scripts/ios/setup_ios.sh

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Configuration de l'environnement iOS ===${NC}"
echo ""

# Vérifier que nous sommes sur macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Ce script doit être exécuté sur macOS${NC}"
    exit 1
fi

# 1. Vérifier et configurer Xcode
echo -e "${BLUE}1. Vérification de Xcode...${NC}"

XCODE_PATH=$(find /Applications -name "Xcode.app" -type d 2>/dev/null | head -1)

if [ -z "$XCODE_PATH" ]; then
    echo -e "${RED}Xcode n'est pas installé${NC}"
    echo ""
    echo -e "${YELLOW}Pour installer Xcode:${NC}"
    echo "1. Ouvrez l'App Store"
    echo "2. Recherchez 'Xcode'"
    echo "3. Cliquez sur 'Obtenir' ou 'Installer'"
    echo ""
    echo -e "${YELLOW}Ou téléchargez depuis: https://developer.apple.com/xcode/${NC}"
    exit 1
fi

echo -e "${GREEN}Xcode trouvé à: $XCODE_PATH${NC}"

# Vérifier la configuration de xcode-select
CURRENT_PATH=$(xcode-select -p 2>/dev/null || echo "")

if [ "$CURRENT_PATH" != "$XCODE_PATH/Contents/Developer" ]; then
    echo -e "${YELLOW}Configuration de xcode-select...${NC}"
    echo -e "${YELLOW}Cette opération nécessite des privilèges administrateur${NC}"
    sudo xcode-select --switch "$XCODE_PATH/Contents/Developer"
    echo -e "${GREEN}xcode-select configuré${NC}"
else
    echo -e "${GREEN}xcode-select est déjà correctement configuré${NC}"
fi

# Accepter la licence Xcode si nécessaire
echo -e "${YELLOW}Vérification de la licence Xcode...${NC}"
if ! sudo xcodebuild -license check 2>/dev/null; then
    echo -e "${YELLOW}Acceptation de la licence Xcode...${NC}"
    echo -e "${YELLOW}Vous devrez peut-être lire et accepter la licence manuellement${NC}"
    sudo xcodebuild -license accept 2>/dev/null || {
        echo -e "${YELLOW}Exécutez manuellement: sudo xcodebuild -license${NC}"
    }
fi

# Exécuter le premier lancement de Xcode
echo -e "${YELLOW}Exécution du premier lancement de Xcode...${NC}"
sudo xcodebuild -runFirstLaunch 2>/dev/null || echo -e "${YELLOW}Premier lancement déjà effectué${NC}"

# 2. Vérifier et installer CocoaPods
echo ""
echo -e "${BLUE}2. Vérification de CocoaPods...${NC}"

if command -v pod &> /dev/null; then
    POD_VERSION=$(pod --version)
    echo -e "${GREEN}CocoaPods est installé (version $POD_VERSION)${NC}"
else
    echo -e "${YELLOW}CocoaPods n'est pas installé${NC}"
    echo -e "${YELLOW}Installation de CocoaPods...${NC}"
    
    # Vérifier si Ruby est disponible
    if ! command -v gem &> /dev/null; then
        echo -e "${RED}Ruby n'est pas installé. CocoaPods nécessite Ruby.${NC}"
        echo -e "${YELLOW}Ruby devrait être installé avec macOS. Vérifiez votre installation.${NC}"
        exit 1
    fi
    
    # Installer CocoaPods
    sudo gem install cocoapods
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}CocoaPods installé avec succès${NC}"
    else
        echo -e "${RED}Erreur lors de l'installation de CocoaPods${NC}"
        echo -e "${YELLOW}Essayez manuellement: sudo gem install cocoapods${NC}"
        exit 1
    fi
fi

# 3. Vérifier Flutter
echo ""
echo -e "${BLUE}3. Vérification de Flutter...${NC}"

if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Flutter n'est pas installé ou n'est pas dans le PATH${NC}"
    echo -e "${YELLOW}Installez Flutter depuis: https://flutter.dev/docs/get-started/install/macos${NC}"
    exit 1
fi

FLUTTER_VERSION=$(flutter --version | head -1)
echo -e "${GREEN}Flutter est installé: $FLUTTER_VERSION${NC}"

# 4. Vérifier flutter doctor
echo ""
echo -e "${BLUE}4. Vérification de la configuration Flutter...${NC}"
echo -e "${YELLOW}Exécution de 'flutter doctor'...${NC}"
echo ""

flutter doctor

echo ""
echo -e "${GREEN}=== Configuration terminée ===${NC}"
echo ""
echo -e "${YELLOW}Prochaines étapes:${NC}"
echo "1. Si des problèmes persistent, suivez les instructions de 'flutter doctor'"
echo "2. Installez les dépendances du projet:"
echo "   cd ios && pod install && cd .."
echo "3. Testez avec: ./scripts/ios/run_simulator.sh --list"
echo ""
