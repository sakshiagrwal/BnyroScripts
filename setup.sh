#!/usr/bin/bash

THEMESDIR=/usr/share/themes
ICONSDIR=/usr/share/icons
GRUBDIR=/boot/grub/themes

DESKTOPAPPS="thunderbird gimp inkscape"
AURPKGS="librewolf-bin android-studio-beta vscodium-bin"
CMDTOOLS="fish helix git wget exa bat duf bottom xh zoxide android-tools yt-dlp ffmpeg"

GTKTHEMES="
	https://github.com/vinceliuice/Orchis-theme
	https://github.com/vinceliuice/Colloid-gtk-theme
	https://github.com/vinceliuice/Layan-gtk-theme
	https://github.com/vinceliuice/WhiteSur-gtk-theme
	https://github.com/EliverLara/Nordic
  https://github.com/ZorinOS/zorin-desktop-themes
	https://github.com/vinceliuice/Graphite-gtk-theme
"

ICONTHEMES="
	https://github.com/vinceliuice/Tela-circle-icon-theme
	https://github.com/yeyushengfan258/Reversal-icon-theme
	https://github.com/vinceliuice/Qogir-icon-theme
	https://github.com/vinceliuice/WhiteSur-icon-theme
	https://github.com/EliverLara/candy-icons
	https://github.com/gvolpe/BeautyLine
  https://github.com/ZorinOS/zorin-icon-themes
	https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
"

GRUBTHEMES="
	https://github.com/vinceliuice/grub2-themes
	https://github.com/sandesh236/sleek--themes
	https://github.com/AdisonCavani/distro-grub-themes
"

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
	# install starship
	curl -sS https://starship.rs/install.sh | sh
	# install bfetch
	sudo cp bfetch /usr/local/bin/bfetch
	sudo chmod +x /usr/local/bin/bfetch
	# install bnyro
	sudo cp bnyro /usr/local/bin/bnyro
	sudo chmod +x /usr/local/bin/bnyro
	# setup fish
	if has fish; then
		chsh -s $(which fish)
		sudo chsh -s $(which fish)
		sudo sed -i 's/bash/fish/' /etc/default/useradd
		cp config.fish ~/.config/fish/config.fish
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
