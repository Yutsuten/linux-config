.PHONY: desktop system tools alacritty fastfetch fish git lftp mpv neomutt nnn nvim utilities vimiv

bold := $(shell tput bold)
reset := $(shell tput sgr0)

all: desktop tools
	@echo ' Add system settings with: `sudo make system`'
	@echo '${bold}Done!${reset}'

desktop:
	@echo '${bold}>> Desktop environment settings <<${reset}'
	mkdir -p ~/.config/sway ~/.config/swaylock ~/.config/waybar ~/.config/dunst ~/.config/gtk-3.0 ~/.config/systemd/user ~/.config/wofi/ ~/.config/pipewire/pipewire-pulse.conf.d
	ln -srf desktop/sway.conf ~/.config/sway/config
	ln -srf desktop/swaylock.conf ~/.config/swaylock/config
	ln -srf desktop/waybar/style.css ~/.config/waybar/style.css
	ln -srf desktop/dunstrc.conf ~/.config/dunst/dunstrc
	ln -srf desktop/gtk/gtk2.ini ~/.gtkrc-2.0
	ln -srf desktop/gtk/gtk3.ini ~/.config/gtk-3.0/settings.ini
	ln -srf desktop/wofi/config ~/.config/wofi/config
	ln -srf desktop/wofi/style.css ~/.config/wofi/style.css
	ln -srf desktop/pipewire/10-remap-sink.conf ~/.config/pipewire/pipewire-pulse.conf.d/10-remap-sink.conf
	ln -srf desktop/bin/nnn ~/.local/bin/nnn
	cp -af desktop/systemd/wallpaper.service ~/.config/systemd/user/wallpaper.service
	cp -af desktop/systemd/wallpaper.timer ~/.config/systemd/user/wallpaper.timer
	cp -af desktop/systemd/trash.service ~/.config/systemd/user/trash.service
	cp -af desktop/systemd/trash.timer ~/.config/systemd/user/trash.timer
	bash desktop/pipewire/90-init.sh
	fish desktop/waybar/configure.fish

system:
	cp -af system/setvtrgb/arc.vga /etc/vtrgb
	cp -af system/setvtrgb/install.sh /etc/initcpio/install/setvtrgb
	cp -af system/setvtrgb/hook.sh /etc/initcpio/hooks/setvtrgb
	cp -af system/utilities/screenshot.sh /usr/local/bin/screenshot
	cp -af system/utilities/openweather.py /usr/local/bin/openweather
	cp -af system/utilities/wallpaper.fish /usr/local/bin/wallpaper
	cp -af system/utilities/system.sh /usr/local/bin/system
	cp -af system/utilities/wp-volume.sh /usr/local/bin/wp-volume
	cp -af system/greetd_conf.toml /etc/greetd/config.toml
	cp -af system/cursor.theme /usr/share/icons/default/index.theme

tools: alacritty fastfetch fish git lftp neomutt nnn nvim vimiv
	@echo ' Add mpv settings with `make mpv`'

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
	ln -srf tools/fish/functions ~/.config/fish/functions

git:
	@echo '${bold}>> Git settings <<${reset}'
	git config --global commit.gpgsign true
	git config --global core.editor 'nvim'
	git config --global core.excludesfile $(CURDIR)/tools/git/gitignore
	git config --global core.pager 'less -+XF -S'
	git config --global init.defaultBranch main
	git config --global pager.branch false
	git config --global pager.stash false
	git config --global push.autoSetupRemote true

lftp:
	@echo '${bold}>> LFTP settings <<${reset}'
	mkdir -p ~/.config/lftp
	ln -srf tools/lftp/lftp.rc ~/.config/lftp/rc

mpv:
	@echo '${bold}>> MPV settings <<${reset}'
	mkdir -p ~/.config/mpv/script-opts
	ln -srf tools/mpv/mpv.conf ~/.config/mpv/mpv.conf
	ln -srf tools/mpv/osc.conf ~/.config/mpv/script-opts/osc.conf

neomutt:
	@echo '${bold}>> Neomutt settings <<${reset}'
	mkdir -p ~/.config/neomutt ~/.cache/neomutt/headers ~/.cache/neomutt/bodies
	ln -srf tools/neomutt/neomuttrc ~/.config/neomutt/neomuttrc

nnn:
	@echo '${bold}>> Nnn plugins <<${reset}'
	rm -rf ~/.config/nnn/plugins
	ln -srnf tools/nnn ~/.config/nnn/plugins

nvim:
	@echo '${bold}>> Neovim settings <<${reset}'
	rm -rf ~/.config/nvim ~/.local/share/nvim/site
	mkdir -p ~/.config/nvim/after ~/.local/share/nvim/site/pack/all
	ln -srf tools/nvim/init.vim ~/.config/nvim/init.vim
	ln -srnf tools/nvim/doc ~/.config/nvim/doc
	ln -srnf tools/nvim/plugin ~/.config/nvim/after/plugin
	ln -srnf tools/nvim/ftplugin ~/.config/nvim/after/ftplugin
	ln -srnf tools/nvim/pack/start ~/.local/share/nvim/site/pack/all/start
	ln -srnf tools/nvim/pack/opt ~/.local/share/nvim/site/pack/all/opt
	nvim --cmd ':helptags ALL | :q' --headless

vimiv:
	@echo '${bold}>> Vimiv settings <<${reset}'
	mkdir -p ~/.config/vimiv
	rm -f ~/.config/vimiv/vimiv.conf ~/.config/vimiv/keys.conf
	ln -srf tools/vimiv/vimiv.conf ~/.config/vimiv/vimiv.conf
	ln -srf tools/vimiv/keys.conf ~/.config/vimiv/keys.conf
