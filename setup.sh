#!/usr/bin/bash

THEMESDIR=/usr/share/themes
ICONSDIR=/usr/share/icons
GRUBDIR=/boot/grub/themes

has() {
	(command -v "$1" &>/dev/null)
}

installtheme() {
	THEMEDIR=~/.themes/
	VERSION="Catppuccin-Mocha-Standard-Rosewater-Dark"
	mkdir -p $THEMEDIR
	wget "https://github.com/catppuccin/gtk/releases/latest/download/$VERSION.zip" \
		-P $THEMEDIR
	cd $THEMEDIR
	unzip $VERSION.zip
	rm -rf $VERSION.zip
	mkdir -p "$HOME/.config/gtk-4.0"
	ln -sf "$THEMEDIR/gtk-4.0/assets" "$HOME/.config/gtk-4.0/assets"
	ln -sf "$THEMEDIR/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
	ln -sf "$THEMEDIR/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"
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
