#!/bin/bash
#
# Fichier qui stocke les réglages de macOS à restaurer
#

## ************************* CONFIGURATION ********************************

## RÉGLAGES DOCK
# Taille du texte au minimum
defaults write com.apple.dock tilesize -int 32
# Agrandissement actif
defaults write com.apple.dock magnification -bool true
# Taille maximale pour l'agrandissement
defaults write com.apple.dock largesize -float 49

## RÉGLAGES FINDER
# Finder : affichage de la barre latérale / affichage par défaut en mode liste / affichage chemin accès / extensions toujours affichées
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder ShowPathbar -bool true
# Afficher le dossier maison par défaut
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
# Recherche dans le dossier en cours par défaut
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Coup d'œîl : sélection de texte
defaults write com.apple.finder QLEnableTextSelection -bool true
# Afficher le dossier maison par défaut
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

## MISSION CONTROL
# Pas d'organisation des bureaux en fonction des apps ouvertes
defaults write com.apple.dock mru-spaces -bool false

## COINS ACTIFS
# En haut à gauche : bureau
defaults write com.apple.dock wvous-tl-corner -int 4
defaults write com.apple.dock wvous-tl-modifier -int 0
# En haut à droite : bureau
defaults write com.apple.dock wvous-tr-corner -int 4
defaults write com.apple.dock wvous-tr-modifier -int 0
# En bas à gauche : bureau
defaults write com.apple.dock wvous-bl-corner -int 2
defaults write com.apple.dock wvous-bl-modifier -int 0
# En bas à droit : bureau
defaults write com.apple.dock wvous-br-corner -int 3
defaults write com.apple.dock wvous-br-modifier -int 0
## CLAVIER ET TRACKPAD
# En bas à droit : bureau
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

## APPS
# Safari : menu développeur / URL en bas à gauche / URL complète en haut / Do Not Track / affichage barre favoris
defaults write com.apple.safari IncludeDevelopMenu -int 1
defaults write com.apple.safari ShowOverlayStatusBar -int 1
defaults write com.apple.safari ShowFullURLInSmartSearchField -int 1
defaults write com.apple.safari SendDoNotTrackHTTPHeader -int 1
defaults write com.apple.safari ShowFavoritesBar -int 1
# TextEdit : .txt par défaut
defaults write com.apple.TextEdit RichText -int 0
