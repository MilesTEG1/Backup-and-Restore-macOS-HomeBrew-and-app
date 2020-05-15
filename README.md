# HomeBrew-Backup-and-Restore-Setup
To backup or restore HomeBrew setup on macOS

I use this website to do my scripts :
[https://tomlankhorst.nl/brew-bundle-restore-backup/](https://tomlankhorst.nl/brew-bundle-restore-backup/)

You need a working setup of HomeBrew. Check this : [https://brew.sh/](https://brew.sh/)

### # Backup & Restore script
Script to backup or restore this :
* Everything installed with HomeBrew (with `brew install`, soit avec `brew cask install` et aussi les `brew tap`)
* Some defaults preferences setup with this commande : `defaults write ...`
* Some configuration files/folders : Oh My Zsh, files/folders in `~/library/...`

You should read carefully all the script to check if everything is good for what you want to do.
During the backup process, the script will check the existence of destination folder ./Fichiers :
If this one exist, it will ask to delete or rename it. (The script must start with a fresh 'Fichiers' folder without anything inside it.
Everything the script will backup will be inside this folder.
Please, don't touch this folder while the script is running.

## **For now, *only the Backup process* is working. I don't have yet coded the restore process...**




---

### # Backup
If youn want to backup the HomeBrew-Setup, execute :
`HomeBrew-Backup-Installation.sh`
it will at first launch this command to be sure [https://github.com/Homebrew/homebrew-bundle](https://github.com/Homebrew/homebrew-bundle) is installed.


It will create a `Brewfile` at the end of process.
If the `Brewfile` file already exists, it will rename it like `Brewfile--2020-05-09--15h17`



### # Restore
If youn want to restore the HomeBrew-Setup you backed up with the previous command, then execute :
`HomeBrew-Restore-Installation.sh`
If the `Brewfile` file doesn't exists, the script will quit without doing anything.
After restoring, (you may have to type your admin passowrd in the process), you should see : `Homebrew Bundle complete! xx Brewfile dependencies now installed.` where xx is the number of entries in the `Brewfile` file. 

### # To check if there anything to install
If you want to check if there anything to install with the `Brewfile` you backed up, then execute :
`HomeBrew-Check-Backup-Installation.sh`
If the `Brewfile` doesn't exists, the script will quit without doing anything.

If you have this message `The Brewfile's dependencies are satisfied.`, then you're done, nothing new to install.

But if you have this message :
````
brew bundle can't satisfy your Brewfile's dependencies.
Satisfy missing dependencies with `brew bundle install`.
````
then, launch the supplied command, or launch my script : `HomeBrew-Restore-Installation.sh`
