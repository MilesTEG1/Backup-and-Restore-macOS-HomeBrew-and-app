#!/bin/sh

## README
# /!\ Ce script d'installation est conçu pour mon usage. Ne le lancez pas sans vérifier chaque commande ! /!\
# Utiliser la commande suivante pour rendre le script exécutable :
# chmod 755 ./HomeBrew-Restore-Installation.sh

## NOTE IMPORTANTE
# Il faudra probablement modifier le script pour l'adapter à vos besoin. !
# Ne l'excécuter pas sans l'avoir lu entièrement afin de vérifier que ce qui est sauvegarder/restaurer
# correspond bien à vos attentes.
#
# Le script sauvegarde ceci :
#       - la liste de tout ce qui a été installé avec HomeBrew (donc soit avec `brew install`, soit avec
#         `brew cask install` et aussi les `brew tap`).
#       - Certains paramètres par défaut (exemple : `defaults write com.apple.dock tilesize -int 32`)
#       - Sauvegarde de certains fichiers de configuration : Oh My Zsh, et certains fichiers/dossiers
#         présents dans ~/Library. Il faudra probablement modifier le script pour l'adapter à vos besoin.
# Lors de la sauvegarde, le script va tester l'existance du dossier de destination ./Fichier :
# Si ce dernier existe, il sera proposé de le supprimer ou de le renommer car le script doit commencer
# avec un dossier vierge.
# Tout ce qui sera sauvegarder (par copie directe ou par archivage) sera contenu dans ce fichier.
# Veillez à ne pas toucher ce dossier pendant l'éxécution du script.
#

## SYNTAX
#
# syntax:   Backup-Restore-Apps-Script.sh [<ARG>]
#           [<ARG>] :   RESTORE
#                       BACKUP
#                       -h ou h ou -help ou help ou --h ou --help

## LICENCE
#
# This  program  is free software: you can redistribute it and/or modify  it
# under the terms of the GNU General Public License as published by the Free
# Software  Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# This  program  is  distributed  in the hope that it will  be  useful,  but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public  License
# for more details.
#
# You  should  have received a copy of the GNU General Public License  along
# with this program. If not, see <http://www.gnu.org/licenses/>

declare -r TRUE=0  # Read-only variable, i.e., a constant.
declare -r FALSE=1 # Read-only variable, i.e., a constant.

declare -r nb_param=$#                           # Nombre d'argument(s) fourni(s) au script.
declare -r param_1="$1"                          # 1er argument fourni
declare -r nom_script=$0                         # Nom du script
declare -r script_dir=$(cd ${0%/*} && pwd -P)    # Chemin complet d'accès du script
declare -r script_dir_rel=$(dirname $0)          # Chemin d'accès relatif du script
declare -r calling_dir=$(pwd)                    # Chemin d'accès complet du dossier de lancement du script (peut différer de script_dir si l'appel du script est fait d'ailleurs...)
declare -r dossier_fichiers=$script_dir/Fichiers # Dossier qui doit exister tout le temps
debug_v=true                                     # Une variable de debug pour tester des bouts de code et pas d'autres
compteur=0                                       # Pour affihcer une numérotation des étapes

################################################################################################################
## On défini des couleurs de texte et de fond, avec des mises en forme.
## Il faut utiliser ${xxxx} juste avant le texte à mettre en forme (avec xxxx = une des variables ci-dessous).
##

BLACK=$(tput setaf 0)   # Pour faire un echo avec le texte en noir
RED=$(tput setaf 1)     # Pour faire un echo avec le texte en rouge
GREEN=$(tput setaf 2)   # Pour faire un echo avec le texte en vert
YELLOW=$(tput setaf 3)  # Pour faire un echo avec le texte en jaune
BLUE=$(tput setaf 4)    # Pour faire un echo avec le texte en bleu
MAGENTA=$(tput setaf 5) # Pour faire un echo avec le texte en magenta
CYAN=$(tput setaf 6)    # Pour faire un echo avec le texte en cyan
WHITE=$(tput setaf 7)   # Pour faire un echo avec le texte en blanc
GREY=$(tput setaf 8)    # Pour faire un echo avec le texte en gris (dans ma config iTerm c'est gris)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
AUTRE_COULEUR=$(tput setaf 180)

BLACK_BG=$(tput setab 0)   # Pour faire un echo avec le fond en noir
RED_BG=$(tput setab 1)     # Pour faire un echo avec le fond en rouge
GREEN_BG=$(tput setab 2)   # Pour faire un echo avec le fond en vert
YELLOW_BG=$(tput setab 3)  # Pour faire un echo avec le fond en jaune
BLUE_BG=$(tput setab 4)    # Pour faire un echo avec le fond en bleu
MAGENTA_BG=$(tput setab 5) # Pour faire un echo avec le fond en magenta
CYAN_BG=$(tput setab 6)    # Pour faire un echo avec le fond en cyan
WHITE_BG=$(tput setab 7)   # Pour faire un echo avec le fond en blanc
GREY_BG=$(tput setab 8)    # Pour faire un echo avec le fond en gris
LIME_YELLOW_BG=$(tput setab 190)
POWDER_BLUE_BG=$(tput setab 153)

BOLD=$(tput bold)      # Pour faire un echo avec le texte en gras (c'est pas vraiment gras...)
NORMAL=$(tput sgr0)    # Pour faire un echo avec le texte normal (on réinitialise toutes les personnalisations)
BLINK=$(tput blink)    # Pour faire un echo avec le texte clignotant
REVERSE=$(tput smso)   # Pour faire un echo avec le texte en négatif
UNDERLINE=$(tput smul) # Pour faire un echo avec le texte souligné
HBRIGHT=$(tput dim)
# tput bold    # Select bold mode
# tput dim     # Select dim (half-bright) mode
# tput smul    # Enable underline mode
# tput rmul    # Disable underline mode
# tput rev     # Turn on reverse video mode
# tput smso    # Enter standout (bold) mode
# tput rmso    # Exit standout mode
##
################################################################################################################

cd $script_dir # On se place dans le dossier du script

f_affiche_parametre() {
    #
    # syntax:   f_affiche_parametre [<argument1> [<argument2>]]
    #           Les arguments sont facultatifs...
    #
    if [ -z "$1" ]; then
        echo "${WHITE}${RED_BG}Aucun paramètre n'a été fourni.${NORMAL}"
    elif [ -n "$2" ]; then
        echo "${YELLOW}Le paramètre fourni ${WHITE}${RED_BG} $1 ${NORMAL}${YELLOW} n'est pas correct. ${NORMAL}"
    else
        echo "${YELLOW}Le nombre de paramètre fourni n'est pas correct : ${WHITE}${RED_BG} $1 ${NORMAL}"
    fi
    echo
    echo "${UNDERLINE}${WHITE}Utilisation du script :${NORMAL}\t${POWDER_BLUE}      $nom_script ${GREEN}[paramètre]${NORMAL}"
    echo
    echo "${UNDERLINE}${WHITE}Liste des [paramètre] utilisables :${NORMAL}${GREEN} BACKUP${NORMAL} ; ${GREEN}RESTORE${NORMAL}"
    echo "${POWDER_BLUE}  - Pour restaurer les applications en utilisant HomeBrew :   ${GREEN}RESTORE${NORMAL}"
    echo "${POWDER_BLUE}  - Pour sauvegarder les applications en utilisant HomeBrew : ${GREEN}BACKUP${NORMAL}"
    echo "${POWDER_BLUE}  - Pour afficher ces consignes : ${GREEN}-h${POWDER_BLUE} ou ${GREEN}h${POWDER_BLUE} ou ${GREEN}-help${POWDER_BLUE} ou ${GREEN}help${POWDER_BLUE} ou -${GREEN}-h${POWDER_BLUE} ou ${GREEN}--help${NORMAL}"
    echo
    echo "${UNDERLINE}${WHITE_BG}${MAGENTA}/!\\    NOTE IMPORTANTE    /!\\${NORMAL}"
    echo "${WHITE}┃${AUTRE_COULEUR} Il faudra probablement modifier le script pour l'adapter à vos besoin. !${NORMAL}"
    echo "${WHITE}┃${AUTRE_COULEUR} Ne l'excécuter pas sans l'avoir lu entièrement afin de vérifier que ce qui est sauvegarder/restaurer${NORMAL}"
    echo "${WHITE}┃${AUTRE_COULEUR} correspond bien à vos attentes.${NORMAL}"
    echo "${WHITE}┃${AUTRE_COULEUR} Le script sauvegarde ceci :${NORMAL}"
    echo "${WHITE}┃${AUTRE_COULEUR}       - la liste de tout ce qui a été installé avec HomeBrew (donc soit avec 'brew install', soit avec${NORMAL}"
    echo "${WHITE}┃${AUTRE_COULEUR}         'brew cask install' et aussi les 'brew tap').${NORMAL}"
    echo "${WHITE}┃${AUTRE_COULEUR}       - Certains paramètres par défaut (exemple : 'defaults write com.apple.dock tilesize -int 32')${NORMAL}"
    echo "${WHITE}┃${AUTRE_COULEUR}       - Sauvegarde de certains fichiers de configuration : Oh My Zsh, et certains fichiers/dossiers${NORMAL}"
    echo "${WHITE}┃${AUTRE_COULEUR}         présents dans ~/Library. Il faudra probablement modifier le script pour l'adapter à vos besoin.${NORMAL}"
    echo "${WHITE}┃${AUTRE_COULEUR} Lors de la sauvegarde, le script va tester l'existance du dossier de destination ./Fichier :${NORMAL}"
    echo "${WHITE}┃${AUTRE_COULEUR} Si ce dernier existe, il sera proposé de le supprimer ou de le renommer car le script doit commencer${NORMAL}"
    echo "${WHITE}┃${AUTRE_COULEUR} avec un dossier vierge.${NORMAL}"
    echo "${WHITE}┃${AUTRE_COULEUR} Tout ce qui sera sauvegarder (par copie directe ou par archivage) sera contenu dans ce fichier.${NORMAL}"
    echo "${WHITE}┃${AUTRE_COULEUR} Veillez à ne pas toucher ce dossier pendant l'éxécution du script.${NORMAL}"
    echo "${WHITE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NORMAL}"
}

confirm() {
    #
    # syntax: confirm [<prompt>]
    #
    #  04 Jul 17   0.1   - Initial version - MEJT
    #  Source : https://mike632t.wordpress.com/2017/07/06/bash-yes-no-prompt/
    #
    local _prompt _default _response

    if [ "$1" ]; then _prompt="$1"; else _prompt="Are you sure"; fi
    _prompt="$_prompt [y/n] ?"

    # Loop forever until the user enters a valid response (Y/N or Yes/No).
    while true; do
        read -r -p "$_prompt " _response
        case "$_response" in
        [Yy][Ee][Ss] | [Yy] | [Oo] | [Oo][Uu][Ii]) # Yes or Y or Oui or O (case-insensitive).
            return $TRUE
            ;;
        [Nn][Oo] | [Nn] | [Nn][Oo][Nn]) # No or N or Non.
            return $FALSE
            ;;
        *) # Anything else (including a blank) is invalid.
            ;;
        esac
    done
}

verif_dossier_existe_suppr_ren_crea() {
    # Fonction qui vérifie si le dossier fourni en paramètre existe.  Si tel est
    # le cas, demande à l'utilisateur s'il faut le supprimer  ou  le renommer et
    # fait l'action correspondante. Puis recrée le dossier pour avoir un dossier
    # vierge de fichiers.
    #
    # syntax: verif_dossier_existe [<dossier_a_tester>]
    #
    #  Utilisation du code suivant :
    #  04 Jul 17   0.1   - Initial version - MEJT
    #  Source : https://mike632t.wordpress.com/2017/07/06/bash-yes-no-prompt/
    #

    local _prompt _default _response res
    local dossier_a_tester
    dossier_a_tester=$1
    res=-1
    if [ -z "$1" ]; then
        echo "Erreur fatale, le paramètre à tester de la fonction verif_dossier_existe_suppr_ren_crea() est vide !"
        exit 99 # On stoppe immédiatement l'exécution de la fonction !
    fi
    if [ -d "$dossier_a_tester" ]; then
        # Si le dossier 'dossier_a_tester' existe on demande s'il faut le supprimer ou le renommer.
        echo "$compteur..... Le dossier $dossier_a_tester existe déjà !"
        echo "$compteur.....        Voulez-vous le supprimer ? (il sera renmomé sinon)"
        _prompt="$compteur.....        Taper Oui pour valider la suppression, ou Non pour le renommer."

        # Loop forever until the user enters a valid response (Y/N or Yes/No).
        while [ "$res" = -1 ]; do
            read -r -p "$_prompt " _response
            case "$_response" in
            [Yy][Ee][Ss] | [Yy] | [Oo] | [Oo][Uu][Ii]) # Yes or Y or Oui or O (case-insensitive).
                res=$TRUE
                # On supprime le dossier
                rm -rf "$dossier_a_tester"
                echo "$compteur.....        Dossier supprimé."
                ;;
            "" | [Nn][Oo] | [Nn] | [Nn][Oo][Nn]) # Blank o No or N or Non (case-insensitive).
                res=$FALSE
                # On renomme le dossier
                mv "$dossier_a_tester" "$dossier_a_tester--$(date +%Y-%m-%d--%Hh%M)"
                echo "$compteur.....        Dossier renommé."
                ;;
            *) # Anything else (including a blank) is invalid.
                ;;
            esac
        done
    fi
    ##read -p "$compteur..... DEBUG Appuyer sur une touche pour continuer..."
    echo "$compteur..... Création du nouveau dossier $dossier_a_tester"
    mkdir -p "$dossier_a_tester" # On crée le dossier CCC-Scripts (et éventuellement le dossier Fichiers, mais ce dernier ne devrait pas ne pas exister)
    return 0
}

ecriture_param_lu() {
    # Fonction pour écrire dans un fichier la valeur d'un paramètre par défaut lu dans la configuration
    # syntax: ecriture_param_lu [<parametre>] [<type>]
    # 1er paramètre : $1
    # 2nd pramètre : $2
    if [ $# -ne 2 ]; then # Si le nombre de paramètre $# fourni à la fonction n'est pas égal à 2
        echo "ERREUR ! Nombre de paramètres fournis à la fonction ecriture_param_lu incohérent."
        echo "Paramètres fournis : $*"
        exit 99
    fi
    local resultat
    resultat=$(defaults read $1)
    case "$2" in
    "bool") # Cas d'une valeur de type Boolean
        if [ "$resultat" = "1" ]; then
            echo "defaults write $1 -bool true" >>$fichier_reglages
        elif [ "$resultat" = "0" ]; then
            echo "defaults write $1 -bool false" >>$fichier_reglages
        else
            echo "Valeur incohérente pour le paramètre $1..."
        fi
        ;;
    "string") # Cas d'une valeur de type string
        chaine_a_trouver="file://${HOME}/"
        if [ $resultat = $chaine_a_trouver ]; then # Si jamais le chemin est le chemin utilisateur...
            echo "defaults write $1 -string \"file://\${HOME}/\"" >>$fichier_reglages
            #elif
            # Si "NSGlobalDomain" ou "com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking"
            # "com.apple.systemsound" ou "com.apple.sound.beep.volume"
            # lancer avec sudo devant
        else
            echo "defaults write $1 -string \"$resultat\"" >>$fichier_reglages
        fi
        ;;
    "int") # Cas d'une valeur de type int
        echo "defaults write $1 -int $resultat" >>$fichier_reglages
        ;;

    "float") # Cas d'une valeur de type float
        echo "defaults write $1 -float $resultat" >>$fichier_reglages
        ;;
    *) # Aucune correpsondance a été trouvée -> ERREUR
        echo "ERREUR ! Valeur incohérente pour le type du paramètre : $1 $2"
        exit 999
        ;;
    esac
}


#########################
# Programme principal
#########################

clear # On efface l'écran
echo "${WHITE}Ce script permet de sauvegarder ou de restaurer les installations faites par HomeBrew. Il permet également de sauvegarder "
echo "les paramètres associés à certaines applications, comme les paramètres de Oh My Zsh, de l'ancien bash, uncrustify...${NORMAL}"
echo

if [ $nb_param -eq 0 ]; then
    # Aucun paramètre n'a été fourni. On va afficher la liste de ce qui peut être utilisé.
    f_affiche_parametre # On appelle la fonction qui affiche l'utilisation des paramètres
    exit
elif [ $nb_param -ge 2 ]; then
    # Au moins 2 paramètres ont été fournis...
    f_affiche_parametre "$*"
    exit
else
    case "$param_1" in
    
    #######################################################################################################
    # Partie Restauration
    #######################################################################################################
    
    {Rr}{Ee}{Ss}{Tt}{Oo}{Rr}{Ee})
        echo
        echo "${RED_BG}${WHITE}Mode RESTAURATION sélectionné${NORMAL}"
        echo
        echo

        vrai_dossier_Library=~/FakeLibrary

        if [ ! -d "$dossier_fichiers" ]; then
            # Le dossier 'dossier_fichiers' n'existe pas. On abandonne la procédure de restauration...
            echo "$compteur..... Le dossier $dossier_fichiers n'existe pas !"
            echo "$compteur..... Il n'y a donc rien à restaurer. Arrêt du script..."
            exit 999
        fi
        echo
        echo "Script d'installation des logiciels les plus utilisés sur mon MAC avec HomeBrew."
        echo
        ((compteur++))
        echo "$compteur..... Installation de Homebrew :"
        ## On vérifie si HomeBrew est déjà installé
        if test ! $(which brew); then
            echo 'Installation de Homebrew'
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        fi
        brew update
        echo

        ((compteur++))
        ## Utilitaires pour les autres apps : Cask et mas (Mac App Store)
        echo '$compteur..... Installation de mas, pour installer les apps du Mac App Store.'
        brew install mas
        echo "$compteur..... Saisir le mail du compte iTunes :"
        read COMPTE
        echo "$compteur..... Saisir le mot de passe du compte : $COMPTE"
        read -s PASSWORD
        mas signin $COMPTE "$PASSWORD"
        echo '$compteur..... Installation de mas, pour installer les apps du Mac App Store.'
        brew install mas
        echo "$compteur..... Vérification de la présence du tap Homebrew/bundle qui va permettre d'utiliser le fichier BrewFile créé lors de la dernière sauvegarde."
        brew tap Homebrew/bundle
        echo

        ((compteur++))
        echo "$compteur..... Installation de tout ce qui été installé avec HomeBrew lors de la"
        echo "$compteur..... précédente sauvegarde."
        echo "$compteur..... Cette opération va prendre du temps... Prenez un café :D"
        # On va se placer dans le dossier Fichier pour utiliser Brewfile
        cd $dossier_fichiers
        if [ -e Brewfile ]; then
            echo "$compteur..... Le fichier Brewfile existe. On peut restaurer son contenu."
            echo "$compteur..... Restauration..."
            brew bundle
            echo "$compteur..... La restauration est terminée."
        else
            echo "$compteur..... Aucun fichier Brewfile n'est présent dans le dossier du script... La restauration est annulée."
        fi

        echo
        ((compteur++))
        echo "$compteur..... Copie des fichiers de préférences/Scripts/Services/workflows sauvegardés :"
        cp $dossier_Prefs/*.plist $vrai_dossier_Library/Preferences/

        echo
        ((compteur++))
        echo "$compteur..... Copie des scripts pour CarbonCopyCloner :"
        sudo cp $dossier_CCC/* /Library/Application\ Support/com.bombich.ccc/Scripts/ # Et on copie les fichiers désirés

        echo
        ((compteur++))
        echo "$compteur..... Restauration des préférences par défauts sauvegardées :"
        if [ -e reglages-macOS.sh ]; then
            # Le fichier reglages-macOS.sh existe, on peut l'exécuter
            ./reglages-macOS.sh
        else
            echo "$compteur..... Le fichier reglages-macOS.sh n'est pas présent dans le dossier Fichiers..."
            echo "$compteur..... La restauration des préférences par défauts est annulée."
        fi

        echo
        ((compteur++))
        echo "$compteur..... Installation de Oh My Zsh :"
        #sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        echo "$compteur..... Installation des plugins Oh My Zsh :"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

        ;;

        ## ---- Partie pour le BACKUP !!
        ##
    

    #######################################################################################################
    # Partie Sauvegarde
    #######################################################################################################

    [Bb][Aa][Cc][Kk][Uu][Pp])
        echo
        echo "${RED_BG}${WHITE}Mode BACKUP sélectionné${NORMAL}"
        echo
        echo
        echo "Sauvegarde des éléments en cours..."
        echo

        # -- DÉBUT d'une étape de sauvegarde -----------------------------------------------------------------------------
        echo "$compteur..... Préparation des dossiers de destination :"
        # On vérifie l'existence ou non du dossier Fichier, on le renomme s'il existe...
        verif_dossier_existe_suppr_ren_crea "$dossier_fichiers" # Appel de la fonction
        # Comme le dossier Fichiers est tout nouveau, on crée directement les dossiers suivants :
        echo "$compteur..... Création des sous-dossiers = CCC-Scripts ; Library ; ZSH_Backup ; Application Support ; Containers ; Preferences."

        # Pour les scripts de Carbon Copy Cloner
        dossier_CCC=$dossier_fichiers/CCC-Scripts # Création de la variable contenant le chemin à sauvegarder
        mkdir "$dossier_CCC"

        # Pour stocker tout ce qu'on va copier depuis le dossier ~/Library/ de l'utilisateur
        dossier_Library=$dossier_fichiers/Library # Création de la variable contenant le chemin à sauvegarder
        mkdir "$dossier_Library"

        # Pour Oh My Zsh
        dossier_ZSH=$dossier_fichiers/ZSH-Backup # Création de la variable contenant le chemin à sauvegarder
        mkdir "$dossier_ZSH"

        # Pour sauvegarder les réglages par défaut
        fichier_reglages=$dossier_fichiers/reglages-macOS.sh

        ## On n'utilise à priori plus ces dossiers
        # # Pour stocker tout ce qui provient du dossier ~/Library/Application Support
        # dossier_AppSupport="$dossier_fichiers/Application Support" # Création de la variable contenant le chemin à sauvegarder
        # mkdir "$dossier_AppSupport"
        #
        # # Dossier pour sauvegarder ce qui se trouve dans ~/Library/Container
        # dossier_Containers="$dossier_fichiers/Containers" # Création de la variable contenant le chemin à sauvegarder
        # mkdir "$dossier_Containers"
        ##

        # Dossier pour sauvegarder ce qui se trouve ~/Library/Preferences
        dossier_Prefs="$dossier_Library/Preferences" # Création de la variable contenant le chemin à sauvegarder
        mkdir "$dossier_Prefs"
        echo "$compteur..... Préparation des dossiers terminée."
        #read -p "Appuyer sur une touche pour continuer..."

        echo
        ((compteur++)) # Fin d'une étape
        # -- FIN d'une étape de sauvegarde -------------------------------------------------------------------------------

        # -- DÉBUT d'une étape de sauvegarde -----------------------------------------------------------------------------
        echo "$compteur..... Sauvegarde de ce que Homebrew à installé et de ce qui a été installé depuis le MacAppStore :"
        ## On vérifie si 'HomeBrew' est déjà installé
        if test ! $(which brew); then
            echo '$compteur..... Installation de Homebrew [ https://brew.sh/ ]'
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        fi
        ## On vérifie que 'mas' est bien installé (ce devrait être le cas... mais sait-on jamais...)
        ## voir ici : https://github.com/mas-cli/mas
        if test ! $(which mas); then
            echo '$compteur..... Installation de mas [ https://github.com/mas-cli/mas ]'
            brew install mas
        fi
        ## Require https://github.com/Homebrew/homebrew-bundle to be installed
        echo "$compteur..... Vérification de la présence de bundle [ https://github.com/Homebrew/homebrew-bundle ]"
        brew tap Homebrew/bundle
        if [ -e Brewfile ]; then
            echo "$compteur..... Le fichier Brewfile existe. On le renomme."
            mv Brewfile Brewfile--$(date +%Y-%m-%d--%Hh%M)
        fi
        echo "$compteur..... Sauvegarde..."
        brew bundle dump
        mv Brewfile "$dossier_fichiers"
        echo "$compteur..... Le fichier Brewfile créé contient les formules HomeBrew installée."
        echo
        ((compteur++)) # Fin d'une étape
        # -- FIN d'une étape de sauvegarde -------------------------------------------------------------------------------

        # -- DÉBUT d'une étape de sauvegarde -----------------------------------------------------------------------------
        echo "$compteur..... Sauvegarde des scripts utilisés par CarbonCopyCloner :"
        cp -R /Library/Application\ Support/com.bombich.ccc/Scripts/ $dossier_CCC # Et on copie les fichiers désirés
        echo "$compteur..... Sauvegarde des scripts utilisés par CarbonCopyCloner terminée."
        echo
        ((compteur++)) # Fin d'une étape
        # -- FIN d'une étape de sauvegarde -------------------------------------------------------------------------------

        # -- DÉBUT d'une étape de sauvegarde -----------------------------------------------------------------------------
        echo "$compteur..... Sauvegarde des paramètres de Oh My Zsh (en archive) :"
        echo "$compteur..... On copie d'abord tous les fichiers dans un dossier ZSH-Backup/.oh-my-zsh :"
        mkdir $dossier_ZSH/.oh-my-zsh                       # Création du sous-dossier nécessaire qui sera supprimé après l'archivage.
        cp -R ~/.oh-my-zsh/custom $dossier_ZSH/.oh-my-zsh/  # Copie du dossier Custom de .oh-my-zsh/
        cp ~/.zsh* ~/.aliases ~/.bash_profile ~/.p10k.zsh $dossier_ZSH/ # Copie des fichiers de configuration de ZSH et de l'ancien bash
        echo "$compteur..... Fin de copie des fichiers Oh My Zsh."
        echo "$compteur..... Compression des fichiers Oh My Zsh..."
        cd $dossier_fichiers                      # On se place dans le dossier contenant celui qu'on veut archiver pour ne pas avoir tout le chemin d'accès dans l'archive...
        tar zcf "./ZSH-Backup.tgz" "./ZSH-Backup" # On n'utilise volontairement pas la variable $dossier_ZSH car sinon le chemin d'accès complet est archivé
        rm -rf $dossier_ZSH                       # On supprime le dossier $dossier_ZSH qui ne servait qu'à faire l'archive.
        cd $script_dir                            # On se place dans le dossier du script
        echo "$compteur..... Fin de compression des fichiers Oh My Zsh."
        echo
        ((compteur++)) # Fin d'une étape
        # -- FIN d'une étape de sauvegarde -------------------------------------------------------------------------------

        # -- DÉBUT d'une étape de sauvegarde -----------------------------------------------------------------------------
        echo "$compteur..... Sauvegarde des dossiers Scripts, Services et Workflows (pour menu clic-droit (création de PDF à partir d'un dossier)) :"
        cp -R ~/Library/Services $dossier_Library/
        cp -R ~/Library/Scripts $dossier_Library/
        cp -R ~/Library/Workflows $dossier_Library/
        # Et comme les scripts de fusion de PDF utilisent le fichier de page blanche, on le copie aussi.
        cp ~/PageBlanche.pdf $dossier_fichiers/ # La copie écrase l'éventuel fichier déjà existant
        echo
        ((compteur++)) # Fin d'une étape
        # -- FIN d'une étape de sauvegarde -------------------------------------------------------------------------------

        # -- DÉBUT d'une étape de sauvegarde -----------------------------------------------------------------------------
        echo "$compteur..... Compression du dossier Git (qui contient certains outils mis à jour avec les commandes GitHub) :"
        cd ~/
        tar zcf $dossier_fichiers/Dossier-Git.tgz Git
        cd $script_dir # On se place dans le dossier du script
        echo
        ((compteur++)) # Fin d'une étape
        # -- FIN d'une étape de sauvegarde -------------------------------------------------------------------------------

        #read -p "Appuyer sur une touche pour continuer..."

        # -- DÉBUT d'une étape de sauvegarde -----------------------------------------------------------------------------
        echo "$compteur..... Compression des dossiers à sauvegarder de Application Support :"
        # Modifier file_to_save qui est la liste des fichiers (pas de dossier) à copier
        #declare -a folder_to_save=("Battery Health 3" "BetterSnapTool" "ForkLift" "Little Snitch" "org.videolan.vlc" "Sublime Text 3" "Tunnelblick" "WhatsApp" "Anki" "Anki2" "Dune Legacy" "iStat Menus")
        declare -a folder_to_save=('Battery Health 3' 'Bartender' 'BetterSnapTool' 'ForkLift' 'reolink' 'Anki' 'Anki2' 'Dune Legacy' 'iStat Menus')
        cd ~/Library/"Application Support"
        tar zcf "$dossier_Library/Application Support.tgz" "${folder_to_save[@]}" # Attention, le contenu de l'archive ne contient que les dossiers, pas l'architecture
        #                                                                         # avec le dossier "Application Support". On nomme donc l'archive avec le même nom que
        #                                                                         # celui du dossier dans lequel on voudra la décompresser.
        cd $script_dir # On se replace dans le dossier du script
        ## Initialement on copiait les dossier... il est plus simple de les archiver directement... Donc ce qui suit n'est plus vraiment utile, mais laissé pour la postérité.
        #cp -R "${folder_to_save[@]}" "$dossier_AppSupport/"
        # for folder in "${folder_to_save[@]}"; do
        #     source_folder=~/Library/Application Support/$folder
        #     cp -R ~/Library/Application\ Support/$folder $dossier_AppSupport/
        # done
        echo
        ((compteur++)) # Fin d'une étape
        # -- FIN d'une étape de sauvegarde -------------------------------------------------------------------------------

        # -- DÉBUT d'une étape de sauvegarde -----------------------------------------------------------------------------
        echo "$compteur..... Sauvegarde des dossiers de Preferences :"
        # Modifier file_to_save qui est la liste des fichiers (pas de dossier) à copier
        declare -a file_to_save=('com.binarynights.ForkLift-3' 'com.googlecode.iterm2*' 'com.hegenberg.BetterSnapTool' 'com.surteesstudios.Bartender' 'org.herf.Flux' 'com.fiplab.batteryhealth3' 'net.tunnelblick.tunnelblick' 'pbs')
        for file in "${file_to_save[@]}"; do
            cp -R ~/Library/Preferences/$file.plist $dossier_Prefs
        done
        echo
        ((compteur++)) # Fin d'une étape
        # -- FIN d'une étape de sauvegarde -------------------------------------------------------------------------------

        ## Modèle de structure pour la copie
        ##
        # -- DÉBUT d'une étape de sauvegarde -----------------------------------------------------------------------------
        # echo "$compteur..... Sauvegarde des fichiers de configuration .blabla du dossier Home :"
        # dossier_XYZ=$dossier_fichiers/XYZ # Création de la variable contenant le chemin à sauvegarder

        # echo "$compteur..... Sauvegarde des fichiers de configuration terminé."
        # echo
        # ((compteur++)) # Fin d'une étape
        # -- FIN d'une étape de sauvegarde -------------------------------------------------------------------------------

        # SAUVEGARDE DES RÉGLAGES PAR DÉFAUT
        #
        # On crée un fichier qui va contenir les réglages
        echo "$compteur..... On récupère certains réglages par défaut qu'on écrit dans le fichier suivant pour être réutilisé à la restauration :"
        echo "$compteur..... $fichier_reglages"

        if [ -e $fichier_reglages ]; then
            #echo "$compteur..... Le fichier $fichier_reglages existe. On le renomme/supprime."
            printf "$compteur..... Le fichier $fichier_reglages existe. Il ne devrait pas !!\nSuppression du fichier.\n"
            #mv $fichier_reglages $fichier_reglages--$(date +%Y-%m-%d--%Hh%M)
            rm -rf "$fichier_reglages"
        fi
        touch "$fichier_reglages"
        echo "#!/bin/bash" >>$fichier_reglages
        echo "#" >>$fichier_reglages
        echo "# Fichier qui stocke les réglages de macOS à restaurer" >>$fichier_reglages
        echo "#" >>$fichier_reglages
        echo "" >>$fichier_reglages
        echo "#### DEBUG !!! À supprimer avec la ligne suivante quand la partie restauration sera au point !" >>$fichier_reglages
        echo "read -p \"Appuyer sur une touche pour continuer...\"" >>$fichier_reglages
        echo "" >>$fichier_reglages
        echo "" >>$fichier_reglages
        echo "## ************************* CONFIGURATION ********************************" >>$fichier_reglages
        echo "" >>$fichier_reglages
        echo "## RÉGLAGES DOCK" >>$fichier_reglages
        echo "# Taille du texte au minimum" >>$fichier_reglages
        ecriture_param_lu "com.apple.dock tilesize" "int"
        echo "# Agrandissement actif" >>$fichier_reglages
        ecriture_param_lu "com.apple.dock magnification" "bool"
        echo "# Taille maximale pour l'agrandissement" >>$fichier_reglages
        ecriture_param_lu "com.apple.dock largesize" "float"

        echo "" >>$fichier_reglages
        echo "## RÉGLAGES FINDER" >>$fichier_reglages
        echo "# Finder : affichage de la barre latérale / affichage par défaut en mode liste / affichage chemin accès / extensions toujours affichées" >>$fichier_reglages
        ecriture_param_lu "com.apple.finder ShowStatusBar" "bool"
        ecriture_param_lu "com.apple.finder FXPreferredViewStyle" "string"
        ecriture_param_lu "com.apple.finder ShowPathbar" "bool"
        #ecriture_param_lu "NSGlobalDomain AppleShowAllExtensions" "bool" # Mettre un sudo devant pour écrire la valeur

        echo "# Afficher le dossier maison par défaut" >>$fichier_reglages
        ecriture_param_lu "com.apple.finder NewWindowTarget" "string"
        ecriture_param_lu "com.apple.finder NewWindowTargetPath" "string"

        echo "# Recherche dans le dossier en cours par défaut" >>$fichier_reglages
        ecriture_param_lu "com.apple.finder FXDefaultSearchScope" "string"

        echo "# Coup d'œîl : sélection de texte" >>$fichier_reglages
        ecriture_param_lu "com.apple.finder QLEnableTextSelection" "bool"

        echo "# Afficher le dossier maison par défaut" >>$fichier_reglages
        ecriture_param_lu "com.apple.desktopservices DSDontWriteNetworkStores" "bool"
        ecriture_param_lu "com.apple.desktopservices DSDontWriteUSBStores" "bool"
        echo "" >>$fichier_reglages

        echo "## MISSION CONTROL" >>$fichier_reglages
        echo "# Pas d'organisation des bureaux en fonction des apps ouvertes" >>$fichier_reglages
        ecriture_param_lu "com.apple.dock mru-spaces" "bool"
        #echo "# Mot de passe demandé immédiatement quand l'économiseur d'écran s'active" >>$fichier_reglages
        #ecriture_param_lu "com.apple.screensaver askForPassword" "int"
        #ecriture_param_lu "com.apple.screensaver askForPasswordDelay" "int"
        echo "" >>$fichier_reglages

        echo "## COINS ACTIFS" >>$fichier_reglages
        echo "# En haut à gauche : bureau" >>$fichier_reglages
        ecriture_param_lu "com.apple.dock wvous-tl-corner" "int"
        ecriture_param_lu "com.apple.dock wvous-tl-modifier" "int"
        echo "# En haut à droite : bureau" >>$fichier_reglages
        ecriture_param_lu "com.apple.dock wvous-tr-corner" "int"
        ecriture_param_lu "com.apple.dock wvous-tr-modifier" "int"
        echo "# En bas à gauche : bureau" >>$fichier_reglages
        ecriture_param_lu "com.apple.dock wvous-bl-corner" "int"
        ecriture_param_lu "com.apple.dock wvous-bl-modifier" "int"
        echo "# En bas à droit : bureau" >>$fichier_reglages
        ecriture_param_lu "com.apple.dock wvous-br-corner" "int"
        ecriture_param_lu "com.apple.dock wvous-br-modifier" "int"

        echo "## CLAVIER ET TRACKPAD" >>$fichier_reglages
        #echo "# Accès au clavier complet (tabulation dans les boîtes de dialogue)" >>$fichier_reglages
        #ecriture_param_lu "NSGlobalDomain AppleKeyboardUIMode" "int" # Mettre un sudo devant pour écrire la valeur
        #echo "# Répétition touches plus rapide" >>$fichier_reglages
        #ecriture_param_lu "NSGlobalDomain KeyRepeat" "int" # Mettre un sudo devant pour écrire la valeur
        #echo "# Délai avant répétition des touches" >>$fichier_reglages
        #ecriture_param_lu "NSGlobalDomain InitialKeyRepeat" "int" # Mettre un sudo devant pour écrire la valeur
        echo "# En bas à droit : bureau" >>$fichier_reglages
        ecriture_param_lu "com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking" "bool"
        echo "" >>$fichier_reglages

        echo "## APPS" >>$fichier_reglages
        echo "# Safari : menu développeur / URL en bas à gauche / URL complète en haut / Do Not Track / affichage barre favoris" >>$fichier_reglages
        ecriture_param_lu "com.apple.safari IncludeDevelopMenu" "int"
        ecriture_param_lu "com.apple.safari ShowOverlayStatusBar" "int"
        ecriture_param_lu "com.apple.safari ShowFullURLInSmartSearchField" "int"
        ecriture_param_lu "com.apple.safari SendDoNotTrackHTTPHeader" "int"
        ecriture_param_lu "com.apple.safari ShowFavoritesBar" "int"
        echo "# TextEdit : .txt par défaut" >>$fichier_reglages
        ecriture_param_lu "com.apple.TextEdit RichText" "int"
        chmod 755 $fichier_reglages

        ;;

    *)
        f_affiche_parametre "$param_1" "param_inc" # On appelle la fonction qui affiche l'utilisation des paramètres
        exit
        ;;
    esac
fi
echo "-----------------------------------  Fin du Script  -----------------------------------"
