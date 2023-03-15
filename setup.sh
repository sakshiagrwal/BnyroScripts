#!/usr/bin/bash

THEMESDIR=/usr/share/themes
ICONSDIR=/usr/share/icons
GRUBDIR=/boot/grub/themes

source programs.sh

has() {
	(command -v "$1" &>/dev/null)
}

gitinstall() { # urls, ./install.sh flags, theme/icons directory
	for link in $1; do
		git clone $link
		dir=${link##*/}
		if [ -f ${dir}/install.sh ]; then
			sudo ./${dir}/install.sh $2
		elif [ -f ${dir}/index.theme ]; then
			sudo mv ${dir} "$3"
		else
			sudo mv ${dir}/* "$3"
		fi
	done
}

installthemes() {
	mkdir ~/Themes
	cd ~/Themes
	echo "Installing GTK Themes ..."
	gitinstall "$GTKTHEMES" "-d $THEMESDIR -t all" "$THEMESDIR"
	echo "Installing Icon Themes ..."
	gitinstall "$ICONTHEMES" "-a -d $ICONSDIR" "$ICONSDIR"
	cd ..
	rm -r Themes
	echo "Downloading Grub Themes ..."
	mkdir $GRUBDIR
	cd $GRUBDIR
	for grub in $GRUBTHEMES; do
		git clone $grub
	done
	echo "Installed themes succesully"
}

installapps() { # apps
	for app in $1; do
		if ! has "$app"; then
			echo "Installing $app"
			has paru && paru -S --noconfirm $app
		fi
		[ $? != 0 ] && echo "Failed to install $app"
	done
}

config() {
	# install bfetch & bnyro
	./bnyro selfinstall
	# setup fish
	if has fish; then
		chsh -s $(which fish)
		sudo chsh -s $(which fish)
		sudo sed -i 's/bash/fish/' /etc/default/useradd
	fi
}

installPM() {
	# install paru
	! has pacman && exit 0
	if ! has paru; then
		sudo pacman -S --needed git base-devel
		git clone https://aur.archlinux.org/paru.git
		cd paru && makepkg -si
		cd .. && rm -r paru
	fi
}
case ${1} in
--headless)
	echo "### Setup without desktop ###"
	installPM
	installapps "$CMDTOOLS"
	config
	;;
--theme)
	installthemes
	;;
--config)
	config
	;;
*)
	echo "### Normal setup ###"
	installPM
	installapps "$DESKTOPAPPS $CMDTOOLS"
	has paru && installapps "$AURPKGS"
	installthemes
	config
	;;
esac
