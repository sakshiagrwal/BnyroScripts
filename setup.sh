#!/usr/bin/bash

THEMESDIR=/usr/share/themes
ICONSDIR=/usr/share/icons
GRUBDIR=/boot/grub/themes

has() {
	(command -v "$1" &>/dev/null)
}

installtheme() {
	VERSION="Catppuccin-Mocha-Standard-Rosewater-Dark"
	mkdir -p ~/.themes
	wget "https://github.com/catppuccin/gtk/releases/latest/download/$VERSION.zip" \
		-P ~/.themes/
	cd ~/.themes/
	unzip $VERSION.zip
	rm -rf $VERSION.zip
}

installapps() { # apps
	for app in $1; do
		if ! has "$app"; then
			xbps-install -Sy "$app"
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

APPS="$(cat programs.txt)"

case ${1} in
--headless)
	installapps "$APPS"
	config
	;;
--theme)
	installtheme
	;;
--config)
	config
	;;
*)
	installapps "$APPS"
	installtheme
	config
	;;
esac
