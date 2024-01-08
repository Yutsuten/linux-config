.PHONY: desktop system tools alacritty fish git mpv nvim nnn utilities vimiv

bold := $(shell tput bold)
reset := $(shell tput sgr0)

all: desktop tools
	@echo '${bold}Done!${reset}'
	@echo ' Add system settings with: `sudo make system`'

desktop:
	@echo '${bold}>> Desktop environment settings <<${reset}'
	mkdir -p ~/.config/sway ~/.config/swaylock ~/.config/waybar ~/.config/dunst ~/.config/gtk-3.0 ~/.config/systemd/user ~/.config/wofi/ ~/.config/pipewire/pipewire-pulse.conf.d
	ln -sf $(CURDIR)/desktop/sway.conf ~/.config/sway/config
	ln -sf $(CURDIR)/desktop/swaylock.conf ~/.config/swaylock/config
	ln -sf $(CURDIR)/desktop/waybar/config.json ~/.config/waybar/config
	ln -sf $(CURDIR)/desktop/waybar/style.css ~/.config/waybar/style.css
	ln -sf $(CURDIR)/desktop/dunstrc.conf ~/.config/dunst/dunstrc
	ln -sf $(CURDIR)/desktop/gtk/gtk2.ini ~/.gtkrc-2.0
	ln -sf $(CURDIR)/desktop/gtk/gtk3.ini ~/.config/gtk-3.0/settings.ini
	ln -sf $(CURDIR)/desktop/wofi/config ~/.config/wofi/config
	ln -sf $(CURDIR)/desktop/wofi/style.css ~/.config/wofi/style.css
	ln -sf $(CURDIR)/desktop/pipewire/10-remap-sink.conf ~/.config/pipewire/pipewire-pulse.conf.d/10-remap-sink.conf
	cp -af $(CURDIR)/desktop/systemd/wallpaper.timer ~/.config/systemd/user/wallpaper.timer
	cp -af $(CURDIR)/desktop/systemd/trash.service ~/.config/systemd/user/trash.service
	cp -af $(CURDIR)/desktop/systemd/trash.timer ~/.config/systemd/user/trash.timer
	bash desktop/systemd/wallpaper.service.sh
	bash desktop/pipewire/90-init.sh

system:
	cp -af $(CURDIR)/system/setvtrgb/arc.vga /etc/vtrgb
	cp -af $(CURDIR)/system/setvtrgb/install.sh /etc/initcpio/install/setvtrgb
	cp -af $(CURDIR)/system/setvtrgb/hook.sh /etc/initcpio/hooks/setvtrgb
	cp -af $(CURDIR)/system/utilities/screenshot.sh /usr/local/bin/screenshot
	cp -af $(CURDIR)/system/utilities/openweather.py /usr/local/bin/openweather
	cp -af $(CURDIR)/system/utilities/wallpaper.py /usr/local/bin/wallpaper
	cp -af $(CURDIR)/system/utilities/system.sh /usr/local/bin/system
	cp -af $(CURDIR)/system/utilities/wp-volume.sh /usr/local/bin/wp-volume
	cp -af $(CURDIR)/system/greetd_conf.toml /etc/greetd/config.toml
	cp -af $(CURDIR)/system/cursor.theme /usr/share/icons/default/index.theme

tools: alacritty fish git mpv nvim nnn vimiv

alacritty:
	@echo '${bold}>> Alacritty settings <<${reset}'
	mkdir -p ~/.config/alacritty
	ln -sf $(CURDIR)/tools/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml

fish:
	@echo '${bold}>> Fish settings <<${reset}'
	rm -f ~/.config/fish/config.fish
	rm -rf ~/.config/fish/functions
	ln -sf $(CURDIR)/tools/fish/config.fish ~/.config/fish/config.fish
	ln -sf $(CURDIR)/tools/fish/functions ~/.config/fish/functions

git:
	@echo '${bold}>> Git settings <<${reset}'
	git config --global core.excludesfile $(CURDIR)/tools/git/gitignore
	git config --global core.pager 'less -+XF -S'
	git config --global pager.branch false
	git config --global core.editor 'nvim'
	git config --global commit.gpgsign true

mpv:
	@echo '${bold}>> MPV settings <<${reset}'
	mkdir -p ~/.config/mpv/script-opts
	ln -sf $(CURDIR)/tools/mpv/mpv.conf ~/.config/mpv/mpv.conf
	ln -sf $(CURDIR)/tools/mpv/input.conf ~/.config/mpv/input.conf
	ln -sf $(CURDIR)/tools/mpv/uosc.conf ~/.config/mpv/script-opts/uosc.conf
	bash tools/mpv/install_plugins.sh

nvim:
	@echo '${bold}>> Neovim settings <<${reset}'
	rm -f ~/.config/nvim/init.vim ~/.config/nvim/*
	rm -rf ~/.local/share/nvim/site/*
	mkdir -p ~/.config/nvim ~/.local/share/nvim/site/pack/all
	ln -sf $(CURDIR)/tools/nvim/init.vim ~/.config/nvim/init.vim
	ln -sf $(CURDIR)/tools/nvim/ginit.vim ~/.config/nvim/ginit.vim
	ln -snf $(CURDIR)/tools/nvim/pack/start ~/.local/share/nvim/site/pack/all/start
	ln -snf $(CURDIR)/tools/nvim/pack/opt ~/.local/share/nvim/site/pack/all/opt
	ln -snf $(CURDIR)/tools/nvim/plugin ~/.local/share/nvim/site/plugin
	ln -snf $(CURDIR)/tools/nvim/ftplugin ~/.local/share/nvim/site/ftplugin
	ln -snf $(CURDIR)/tools/nvim/doc ~/.local/share/nvim/site/doc

nnn:
	@echo '${bold}>> Nnn plugins <<${reset}'
	mkdir -p ~/.config/nnn
	rm -rf ~/.config/nnn/plugins
	ln -sf $(CURDIR)/tools/nnn/plugins ~/.config/nnn/plugins

vimiv:
	@echo '${bold}>> Vimiv settings <<${reset}'
	mkdir -p ~/.config/vimiv
	rm -f ~/.config/vimiv/vimiv.conf ~/.config/vimiv/keys.conf
	ln -sf $(CURDIR)/tools/vimiv/vimiv.conf ~/.config/vimiv/vimiv.conf
	ln -sf $(CURDIR)/tools/vimiv/keys.conf ~/.config/vimiv/keys.conf
