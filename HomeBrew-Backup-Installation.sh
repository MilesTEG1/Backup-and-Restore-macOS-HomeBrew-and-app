#!/bin/sh
# Utiliser la commande suivante pour rendre le script exécutable :
# chmod 755 ./Backup-HomeBrew-Installation.sh
echo "Script de sauvegarde de l'installation HomeBrew."

# Require https://github.com/Homebrew/homebrew-bundle to be installed
echo "Vérification de la présence de blundle"
brew tap Homebrew/bundle
if [ -e Brewfile ]
then
    echo "Le fichier Brewfile existe. On le renomme."
    mv Brewfile Brewfile--`date +%Y-%m-%d--%Hh%M`
fi
echo "Sauvegarde..."
brew bundle dump
echo "Le fichier Brewfile créé contient les formules HomeBrew installée."
echo "La sauvegarde est terminée."