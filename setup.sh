#!/usr/bin/bash

THEMESDIR=/usr/share/themes
ICONSDIR=/usr/share/icons
FONTSDIR=/usr/share/fonts
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

installfont() {
	FONTVARIANT="JetBrainsMono"
	wget "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FONTVARIANT.zip"
	unzip "$FONTVARIANT".zip
	mv "$FONTVARIANT"/*.ttf "$FONTSDIR"/ttf/
	rm -rf "$FONTVARIANT" "$FONTVARIANT".zip
}

getdotfiles() {
	git clone git@github.com:Bnyro/dotfiles.git
	rm -rf ~/.config
	mv dotfiles ~/.config
}

installui() {
	installtheme
	installfont
	getdotfiles
}

installapps() { # apps
	for app in $1; do
		if ! has "$app"; then
			xbps-install -Sy "$app" || echo "Failed to install $app"
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
		sudo sed -i 's/bash/fish/g' /etc/default/useradd
	fi
	# enable sudo warning forever
	echo "Defaults	lecture = always" | sudo tee /etc/sudoers.d/privacy
}

APPS="$(cat programs.txt)"

case ${1} in
--headless)
	installapps "$APPS"
	config
	;;
--theme)
	installui
	;;
--config)
	config
	;;
*)
	installapps "$APPS"
	installui
	config
	;;
esac
