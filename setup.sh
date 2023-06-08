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

getdotfiles() {
	git clone git@github.com:Bnyro/dotfiles.git
	rm -rf ~/.config
	mv dotfiles ~/.config
}

installui() {
	installtheme
	getdotfiles
}

installapps() { # apps
	for app in $1; do
		if ! has "$app"; then
			sudo xbps-install -Sy "$app" || echo "Failed to install $app"
		fi
		[ $? != 0 ] && echo "Failed to install $app"
	done
}

config() {
	# install bfetch & bnyro
	./bnyro selfinstall
	# enable sudo warning forever
	echo "Defaults	lecture = always" | sudo tee /etc/sudoers.d/privacy
	# set bash as default shell
	chsh -s $(which bash)
	sudo chsh -s $(which bash)
	sudo sed -i 's/bash/bash/g' /etc/default/useradd
	# install ble.sh
	BLESH_URL=$(curl -s "https://api.github.com/repos/akinomyoga/ble.sh/releases/latest" |
		jq ".assets[0].browser_download_url" | tr -d '"')
	BLESH_BASE=$(basename "$BLESH_URL" ".tar.xz")
	wget "$BLESH_URL"
	tar xvf "$BLESH_BASE.tar.xz"
	mv "$BLESH_BASE" ~/blesh
	echo ". ~/config/bash/config.sh" >> ~/.bashrc
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
