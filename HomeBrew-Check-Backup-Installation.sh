#!/bin/sh
# Utiliser la commande suivante pour rendre le script exécutable :
# chmod 755 ./HomeBrew-Check-Backup-Installation.sh

#Require https://github.com/Homebrew/homebrew-bundle to be installed

echo "Script de vérification s'il y a quelque chose à installer depuis le backup Brewfile."
if [ -e Brewfile ]
then
    brew bundle check
fi