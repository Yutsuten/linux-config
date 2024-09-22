.PHONY: build desktop system tools alacritty fastfetch fish git helix lftp mpv neomutt nnn nvim utilities vimiv zellij

bold := $(shell tput bold)
reset := $(shell tput sgr0)

config: desktop tools
	@echo ' Add system settings with: `sudo make system`'
	@echo '${bold}Done!${reset}'

build:
	@echo '${bold}>> Compile rust apps <<${reset}'
	mkdir -p ~/.local/bin
	cd rust/openweather && RUSTFLAGS='-C target-cpu=native' cargo build --release
	cd rust/record-settings && RUSTFLAGS='-C target-cpu=native' cargo build --release && cp -af target/release/record-settings ~/.local/bin/record-settings
	cd rust/wallpaper && RUSTFLAGS='-C target-cpu=native' cargo build --release

desktop:
	@echo '${bold}>> Desktop environment settings <<${reset}'
	mkdir -p ~/.config/sway ~/.config/swaylock ~/.config/waybar ~/.config/dunst ~/.config/gtk-3.0 ~/.config/gtk-4.0 ~/.config/systemd/user ~/.config/wofi/ ~/.config/pipewire/pipewire-pulse.conf.d ~/.local/share/applications ~/.local/bin
	ln -srf desktop/sway.conf ~/.config/sway/config
	ln -srf desktop/swaylock.conf ~/.config/swaylock/config
	ln -srf desktop/waybar/style.css ~/.config/waybar/style.css
	ln -srf desktop/dunstrc.conf ~/.config/dunst/dunstrc
	ln -srf desktop/gtk/gtk3.ini ~/.config/gtk-3.0/settings.ini
	ln -srf desktop/gtk/gtk3.ini ~/.config/gtk-4.0/settings.ini
	ln -srf desktop/wofi/config ~/.config/wofi/config
	ln -srf desktop/wofi/style.css ~/.config/wofi/style.css
	ln -srf desktop/pipewire/10-remap-sink.conf ~/.config/pipewire/pipewire-pulse.conf.d/10-remap-sink.conf
	ln -srf desktop/bin/* ~/.local/bin/
	ln -srf desktop/entries/*.desktop ~/.local/share/applications/
	sed "s#{WALLPAPERS_PATH}#$$WALLPAPERS_PATH#g" desktop/systemd/wallpaper.service > ~/.config/systemd/user/wallpaper.service
	sed "s#{HOME}#$$HOME#g" desktop/systemd/caddy.service > ~/.config/systemd/user/caddy.service
	sed -e "s#\[LOCAL_IP\]#$$(ip address | sed -nE 's# *inet (192[^/]+)/.*#\1#p')#g" -e "s#\[HOME\]#$$HOME#g" desktop/systemd/Caddyfile > ~/.local/server/Caddyfile
	cp -af desktop/systemd/wallpaper.timer ~/.config/systemd/user/wallpaper.timer
	cp -af desktop/systemd/trash.service ~/.config/systemd/user/trash.service
	cp -af desktop/systemd/trash.timer ~/.config/systemd/user/trash.timer
	bash desktop/pipewire/90-init.sh
	fish desktop/waybar/configure.fish
	xdg-mime default extract.desktop application/gzip
	xdg-mime default extract.desktop application/x-rar
	xdg-mime default extract.desktop application/x-tar
	xdg-mime default extract.desktop application/x-xz
	xdg-mime default extract.desktop application/zip
	xdg-mime default extract.desktop application/zstd
	xdg-mime default firefox.desktop text/plain
	xdg-mime default gpgopen.desktop application/octet-stream
	xdg-mime default mpv.desktop audio/flac
	xdg-mime default mpv.desktop image/avif
	xdg-mime default mpv.desktop image/heif
	xdg-mime default mpv.desktop image/tiff
	xdg-mime default mpv.desktop video/webm
	xdg-mime default vimiv.desktop image/bmp
	xdg-mime default vimiv.desktop image/gif
	xdg-mime default vimiv.desktop image/ico
	xdg-mime default vimiv.desktop image/jpeg
	xdg-mime default vimiv.desktop image/png
	xdg-mime default vimiv.desktop image/svg
	xdg-mime default vimiv.desktop image/webp

system:
	cp -af rust/openweather/target/release/openweather /usr/local/bin/openweather
	cp -af rust/wallpaper/target/release/wallpaper /usr/local/bin/wallpaper
	cp -af system/setvtrgb/arc.vga /etc/vtrgb
	cp -af system/setvtrgb/install.sh /etc/initcpio/install/setvtrgb
	cp -af system/setvtrgb/hook.sh /etc/initcpio/hooks/setvtrgb
	cp -af system/utilities/record.fish /usr/local/bin/record
	cp -af system/utilities/screenshot.sh /usr/local/bin/screenshot
	cp -af system/utilities/system.sh /usr/local/bin/system
	cp -af system/utilities/toggle-record.fish /usr/local/bin/toggle-record
	cp -af system/utilities/wp-volume.sh /usr/local/bin/wp-volume
	cp -af system/greetd_conf.toml /etc/greetd/config.toml
	cp -af system/cursor.theme /usr/share/icons/default/index.theme
	fish system/misc.fish

tools: alacritty fastfetch fish git helix lftp mpv neomutt nnn nvim vimiv zellij

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
	git config --global core.editor 'helix'
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
	ln -srf tools/helix/ignore ~/.config/helix/ignore
	ln -srf tools/helix/languages.toml ~/.config/helix/languages.toml
	ln -srnf tools/helix/themes ~/.config/helix/themes

lftp:
	@echo '${bold}>> LFTP settings <<${reset}'
	mkdir -p ~/.config/lftp
	ln -srf tools/lftp/lftp.rc ~/.config/lftp/rc

mpv:
	@echo '${bold}>> MPV settings <<${reset}'
	mkdir -p ~/.config/mpv/script-opts
	ln -srf tools/mpv/mpv.conf ~/.config/mpv/mpv.conf
	ln -srf tools/mpv/input.conf ~/.config/mpv/input.conf
	ln -srf tools/mpv/osc.conf ~/.config/mpv/script-opts/osc.conf

neomutt:
	@echo '${bold}>> Neomutt settings <<${reset}'
	mkdir -p ~/.config/neomutt ~/.cache/neomutt/headers ~/.cache/neomutt/bodies
	ln -srf tools/neomutt/neomuttrc ~/.config/neomutt/neomuttrc

nnn:
	@echo '${bold}>> Nnn plugins <<${reset}'
	mkdir -p ~/.config/nnn
	ln -srnf tools/nnn ~/.config/nnn/plugins

nvim:
	@echo '${bold}>> Neovim settings <<${reset}'
	rm -rf ~/.config/nvim ~/.local/share/nvim/site
	mkdir -p ~/.config/nvim/after ~/.local/share/nvim/site/pack/all
	ln -srf tools/nvim/init.vim ~/.config/nvim/init.vim
	ln -srnf tools/nvim/colors ~/.config/nvim/colors
	ln -srnf tools/nvim/doc ~/.config/nvim/doc
	ln -srnf tools/nvim/plugin ~/.config/nvim/after/plugin
	ln -srnf tools/nvim/ftplugin ~/.config/nvim/after/ftplugin
	ln -srnf tools/nvim/pack/start ~/.local/share/nvim/site/pack/all/start
	ln -srnf tools/nvim/pack/opt ~/.local/share/nvim/site/pack/all/opt
	nvim --cmd ':helptags ALL | :q' --headless

vimiv:
	@echo '${bold}>> Vimiv settings <<${reset}'
	mkdir -p ~/.config/vimiv
	ln -srf tools/vimiv/vimiv.conf ~/.config/vimiv/vimiv.conf
	ln -srf tools/vimiv/keys.conf ~/.config/vimiv/keys.conf

zellij:
	@echo '${bold}>> Zellij settings <<${reset}'
	ln -srnf tools/zellij ~/.config/zellij
