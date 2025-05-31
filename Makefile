.PHONY: build desktop mime system tools alacritty fastfetch fish git helix less lftp mpv neomutt nnn utilities zellij

bold := $(shell tput bold)
reset := $(shell tput sgr0)

config: desktop tools
	@echo ' Add system settings with: `sudo make system`'
	@echo '${bold}Done!${reset}'

build:
	@echo '${bold}>> Compile rust apps <<${reset}'
	mkdir -p ~/.local/bin
	cd rust/openweather && RUSTFLAGS='-C target-cpu=native' cargo build --release && cp -af target/release/openweather ~/.local/bin/openweather
	cd rust/record-reencoder && RUSTFLAGS='-C target-cpu=native' cargo build --release && cp -af target/release/record-reencoder ~/.local/bin/record-reencoder
	cd rust/record-settings && RUSTFLAGS='-C target-cpu=native' cargo build --release && cp -af target/release/record-settings ~/.local/bin/record-settings
	cd rust/wallpaper && RUSTFLAGS='-C target-cpu=native' cargo build --release && cp -af target/release/wallpaper ~/.local/bin/wallpaper

desktop: mime
	@echo '${bold}>> Desktop environment settings <<${reset}'
	mkdir -p ~/.config/sway ~/.config/swaylock ~/.config/waybar ~/.config/dunst ~/.config/gtk-3.0 ~/.config/gtk-4.0 ~/.config/systemd/user ~/.config/wofi/ ~/.local/share/applications ~/.local/bin ~/.local/server
	ln -srf desktop/sway.conf ~/.config/sway/config
	ln -srf desktop/swaylock.conf ~/.config/swaylock/config
	ln -srf desktop/waybar/style.css ~/.config/waybar/style.css
	ln -srf desktop/gtk/gtk3.ini ~/.config/gtk-3.0/settings.ini
	ln -srf desktop/gtk/gtk3.ini ~/.config/gtk-4.0/settings.ini
	ln -srf desktop/wofi/config ~/.config/wofi/config
	ln -srf desktop/wofi/style.css ~/.config/wofi/style.css
	ln -srf desktop/bin/* ~/.local/bin/ && find ~/.local/bin -xtype l -delete
	ln -srf desktop/entries/*.desktop ~/.local/share/applications/ && find ~/.local/share/applications -xtype l -delete
	sed -e "s#{HOME}#$$HOME#g" -e "s#{WALLPAPERS_PATH}#$$WALLPAPERS_PATH#g" desktop/systemd/wallpaper.service > ~/.config/systemd/user/wallpaper.service
	sed "s#{HOME}#$$HOME#g" desktop/systemd/caddy.service > ~/.config/systemd/user/caddy.service
	sed -e "s#\[LOCAL_IP\]#$$(ip address | sed -nE 's# *inet (192[^/]+)/.*#\1#p')#g" -e "s#\[HOME\]#$$HOME#g" desktop/systemd/Caddyfile > ~/.local/server/Caddyfile
	cp -af desktop/systemd/wallpaper.timer ~/.config/systemd/user/wallpaper.timer
	cp -af desktop/systemd/trash.service ~/.config/systemd/user/trash.service
	cp -af desktop/systemd/trash.timer ~/.config/systemd/user/trash.timer
	fish desktop/dunst/configure.fish
	fish desktop/pipewire/configure.fish
	fish desktop/waybar/configure.fish

mime:
	@echo '${bold}>> Xdg mime <<${reset}'
	xdg-mime default firefox.desktop text/plain
	xdg-mime default gpg-open.desktop application/octet-stream
	xdg-mime default mpv.desktop audio/flac
	xdg-mime default mpv.desktop audio/ogg
	xdg-mime default mpv.desktop video/webm
	xdg-mime default mvi.desktop image/avif
	xdg-mime default mvi.desktop image/bmp
	xdg-mime default mvi.desktop image/gif
	xdg-mime default mvi.desktop image/heic
	xdg-mime default mvi.desktop image/heif
	xdg-mime default mvi.desktop image/ico
	xdg-mime default mvi.desktop image/jpeg
	xdg-mime default mvi.desktop image/png
	xdg-mime default mvi.desktop image/svg
	xdg-mime default mvi.desktop image/svg+xml
	xdg-mime default mvi.desktop image/tiff
	xdg-mime default mvi.desktop image/webp

system:
	cp -af system/setvtrgb/arc.vga /etc/vtrgb
	cp -af system/setvtrgb/install.sh /etc/initcpio/install/setvtrgb
	cp -af system/setvtrgb/hook.sh /etc/initcpio/hooks/setvtrgb
	cp -af system/utilities/record.fish /usr/local/bin/record
	cp -af system/utilities/screenshot.fish /usr/local/bin/screenshot
	cp -af system/utilities/system.fish /usr/local/bin/system
	cp -af system/utilities/toggle-record.fish /usr/local/bin/toggle-record
	cp -af system/utilities/wp-volume.fish /usr/local/bin/wp-volume
	cp -af system/greetd_conf.toml /etc/greetd/config.toml
	cp -af system/cursor.theme /usr/share/icons/default/index.theme
	fish system/misc.fish

tools: alacritty fastfetch fish git helix less lftp mpv neomutt nnn zellij

alacritty:
	@echo '${bold}>> Alacritty settings <<${reset}'
	mkdir -p ~/.config/alacritty
	ln -srf tools/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml

fastfetch:
	@echo '${bold}>> Fastfetch settings <<${reset}'
	mkdir -p ~/.config/fastfetch
	ln -srf tools/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc

fish:
	@echo '${bold}>> Fish settings <<${reset}'
	rm -f ~/.config/fish/config.fish
	rm -rf ~/.config/fish/functions
	ln -srf tools/fish/config.fish ~/.config/fish/config.fish
	ln -srnf tools/fish/functions ~/.config/fish/functions

git:
	@echo '${bold}>> Git settings <<${reset}'
	git config --global commit.gpgsign true
	git config --global core.editor 'hx'
	git config --global core.excludesfile $(CURDIR)/tools/git/gitignore
	git config --global core.pager 'less -+XF -S'
	git config --global init.defaultBranch main
	git config --global pager.branch false
	git config --global pager.stash false
	git config --global push.autoSetupRemote true

helix:
	@echo '${bold}>> Helix settings <<${reset}'
	mkdir -p ~/.config/helix
	ln -srf tools/helix/config.toml ~/.config/helix/config.toml
	ln -srf tools/helix/languages.toml ~/.config/helix/languages.toml
	ln -srnf tools/helix/themes ~/.config/helix/themes

less:
	@echo '${bold}>> Less settings <<${reset}'
	ln -srnf tools/less ~/.config/less

lftp:
	@echo '${bold}>> LFTP settings <<${reset}'
	mkdir -p ~/.config/lftp
	ln -srf tools/lftp/lftp.rc ~/.config/lftp/rc

mpv:
	@echo '${bold}>> MPV settings <<${reset}'
	ln -srnf tools/mpv ~/.config/mpv
	ln -srnf tools/mvi ~/.config/mvi

neomutt:
	@echo '${bold}>> Neomutt settings <<${reset}'
	mkdir -p ~/.config/neomutt ~/.cache/neomutt/headers ~/.cache/neomutt/bodies
	ln -srf tools/neomutt/neomuttrc ~/.config/neomutt/neomuttrc

nnn:
	@echo '${bold}>> Nnn plugins <<${reset}'
	mkdir -p ~/.config/nnn/plugins ~/.local/share/nnn
	ln -srf tools/nnn/plugins/.utils tools/nnn/plugins/* ~/.config/nnn/plugins && find ~/.config/nnn/plugins -xtype l -delete
	ln -srnf tools/nnn/file_templates ~/.config/nnn/file_templates

zellij:
	@echo '${bold}>> Zellij settings <<${reset}'
	mkdir -p ~/.local/share/zellij
	ln -srnf tools/zellij ~/.config/zellij
