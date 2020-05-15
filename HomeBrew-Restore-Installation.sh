#!/bin/sh
# Utiliser la commande suivante pour rendre le script exécutable :
# chmod 755 ./HomeBrew-Restore-Installation.sh

#Require https://github.com/Homebrew/homebrew-bundle to be installed
echo "Script de restauration de l'installation HomeBrew."
if [ -e Brewfile ]
then
    echo "Vérification de la présence de blundle"
    brew tap Homebrew/bundle
    echo "Le fichier Brewfile existe. On peut restaurer son contenu."
    echo "Restauration..."
    brew bundle
    echo "La restauration est terminée."
else
    echo "Aucun fichier Brewfile n'est présent dans le dossier du script... La restauration est annulée."
fi
