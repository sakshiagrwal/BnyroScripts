#!/usr/bin/bash

THEMESDIR=/usr/share/themes
ICONSDIR=/usr/share/icons

DESKTOPAPPS="insomnia filezilla librewolf thunderbird grub-customizer gimp inkscape arduino android-studio noisetorch vscodium"
CMDTOOLS="fish nvim git wget exa bat duf autojump ffmpeg android-tools pyton-pip"

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
			./${dir}/install.sh $2
		elif [ -f ${dir}/index.theme ]; then
			mv ${dir} "$3"
    else 
      mv ${dir}/* "$3"
		fi
	done
}

installthemes() {
	mkdir ~/Themes
	cd ~/Themes
	echo "# Installing GTK Themes ..."
	gitinstall "$GTKTHEMES" "-d $THEMESDIR -t all" "$THEMESDIR"
	echo "# Installing Icon Themes ..."
	gitinstall "$ICONTHEMES" "-a -d $ICONSDIR" "$ICONSDIR"
	cd ..
    rm -r Themes
	echo "# Downloading Grub Themes ..."
	mkdir ~/Grub
	cd ~/Grub
	for grub in $GRUBTHEMES; do
		git clone $grub
	done
	echo "# Installed themes succesully"
}

installapps() { # apps
	for app in $1; do
		if ! has "$app"; then
			echo "# Installing $app"
			has apt && apt install -y $app
			has paru && paru -S --noconfirm $app
			has dnf && dnf -y install $app
            has apk && apk add $app
		fi
		[ $? != 0 ] && echo "# Failed to install $app"
	done
}

config() {
    # install yt-dlp
	wget -q https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp &&
    chmod a+rx /usr/local/bin/yt-dlp
    # install starship
    curl -sS https://starship.rs/install.sh | sh
    # install bfetch
    cp bfetch /usr/local/bin/bfetch
    chmod +x /usr/local/bin/bfetch
	# install bnyro
	cp bnyro /usr/local/bin/bnyro
	chmod +x /usr/local/bin/bnyro
    # setup fish
	if has fish; then
		chsh -s $(which fish)
		chsh -s $(which fish)
		sed -i 's/bash/fish/' /etc/default/useradd
    echo 'alias ls="exa -TlaL 2 --icons"
        alias df="duf /"
        set fish_greeting
        bfetch
        starship init fish | source' > ~/.config/fish/config.fish
	fi
    # install lunarvim
    has nvim && bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
}

installPM() {
    # install paru
	if has pacman && ! has paru; then
		pacman -S --needed git base-devel
		git clone https://aur.archlinux.org/paru.git
		cd paru && makepkg -si
		cd .. && rm -r paru
	fi
    # install nala
	if has apt && ! has nala; then
		echo "deb [arch=amd64,arm64,armhf] http://deb.volian.org/volian/ scar main" | tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
		wget -qO- https://deb.volian.org/volian/scar.key | tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg >/dev/null
		apt update
		apt install -y nala
	fi
}

# check for root permissions
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

case ${1} in
--headless)
    echo "### Setup without desktop ###"
    installPM
    installapps "$CMDTOOLS"
    installthemes
    config
    ;;
*)
    echo "### Normal setup ###"
    installPM
    installapps "$DESKTOPAPPS $CMDTOOLS"
    config
    ;;
esac
