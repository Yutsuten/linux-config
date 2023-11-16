.PHONY: alacritty fish git mpv neovim nnn utilities system vimiv wm test

bold := $(shell tput bold)
reset := $(shell tput sgr0)

all: alacritty fish git mpv neovim nnn utilities vimiv wm
	@echo '${bold}Done!${reset}'
	@echo ' Add system settings with: `sudo make system`'

alacritty:
	@echo '${bold}>> Alacritty settings <<${reset}'
	mkdir -p ~/.config/alacritty
	ln -sf $(CURDIR)/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

fish:
	@echo '${bold}>> Fish settings <<${reset}'
	rm -f ~/.config/fish/config.fish
	ln -sf $(CURDIR)/fish/config.fish ~/.config/fish/config.fish
	ln -sf $(CURDIR)/fish/sway.fish ~/.config/fish/conf.d/sway.fish
	ln -sf $(CURDIR)/fish/functions ~/.config/fish/functions

git:
	@echo '${bold}>> Git settings <<${reset}'
	git config --global core.excludesfile $(CURDIR)/git/gitignore
	git config --global core.pager 'less -+XF -S'
	git config --global core.editor 'nvim'

mpv:
	@echo '${bold}>> MPV settings <<${reset}'
	mkdir -p ~/.config/mpv/script-opts
	ln -sf $(CURDIR)/mpv/mpv.conf ~/.config/mpv/mpv.conf
	ln -sf $(CURDIR)/mpv/input.conf ~/.config/mpv/input.conf
	ln -sf $(CURDIR)/mpv/uosc.conf ~/.config/mpv/script-opts/uosc.conf
	bash mpv/install_plugins.sh

neovim:
	@echo '${bold}>> Neovim settings <<${reset}'
	rm -f ~/.config/nvim/init.vim ~/.config/nvim/*
	rm -rf ~/.local/share/nvim/site/*
	mkdir -p ~/.config/nvim ~/.local/share/nvim/site/pack/all
	ln -sf $(CURDIR)/neovim/init.vim ~/.config/nvim/init.vim
	ln -sf $(CURDIR)/neovim/ginit.vim ~/.config/nvim/ginit.vim
	ln -snf $(CURDIR)/neovim/pack/start ~/.local/share/nvim/site/pack/all/start
	ln -snf $(CURDIR)/neovim/pack/opt ~/.local/share/nvim/site/pack/all/opt
	ln -snf $(CURDIR)/neovim/plugin ~/.local/share/nvim/site/plugin
	ln -snf $(CURDIR)/neovim/ftplugin ~/.local/share/nvim/site/ftplugin
	ln -snf $(CURDIR)/neovim/doc ~/.local/share/nvim/site/doc

nnn:
	@echo '${bold}>> Nnn plugins <<${reset}'
	rm -rf ~/.config/nnn/plugins
	ln -sf $(CURDIR)/nnn/plugins ~/.config/nnn/plugins

system:
	cp -af $(CURDIR)/utilities/screenshot.sh /usr/local/bin/screenshot
	cp -af $(CURDIR)/utilities/openweather.py /usr/local/bin/openweather
	cp -af $(CURDIR)/utilities/wallpaper.py /usr/local/bin/wallpaper
	cp -af $(CURDIR)/utilities/system.sh /usr/local/bin/system
	cp -af $(CURDIR)/utilities/wp-volume.sh /usr/local/bin/wp-volume
	cp -af $(CURDIR)/window_manager/greetd_conf.toml /etc/greetd/config.toml

vimiv:
	@echo '${bold}>> Vimiv settings <<${reset}'
	mkdir -p ~/.config/vimiv
	rm -f ~/.config/vimiv/vimiv.conf ~/.config/vimiv/keys.conf
	ln -sf $(CURDIR)/vimiv/vimiv.conf ~/.config/vimiv/vimiv.conf
	ln -sf $(CURDIR)/vimiv/keys.conf ~/.config/vimiv/keys.conf

wm:
	@echo '${bold}>> Window manager settings <<${reset}'
	mkdir -p ~/.config/sway ~/.config/swaylock ~/.config/waybar ~/.config/dunst ~/.config/gtk-3.0 ~/.config/systemd/user ~/.config/wofi/ ~/.config/pipewire/pipewire-pulse.conf.d
	ln -sf $(CURDIR)/window_manager/sway.conf ~/.config/sway/config
	ln -sf $(CURDIR)/window_manager/swaylock.conf ~/.config/swaylock/config
	ln -sf $(CURDIR)/window_manager/waybar/config.json ~/.config/waybar/config
	ln -sf $(CURDIR)/window_manager/waybar/style.css ~/.config/waybar/style.css
	ln -sf $(CURDIR)/window_manager/dunstrc.conf ~/.config/dunst/dunstrc
	ln -sf $(CURDIR)/window_manager/gtk/gtk2.ini ~/.gtkrc-2.0
	ln -sf $(CURDIR)/window_manager/gtk/gtk3.ini ~/.config/gtk-3.0/settings.ini
	ln -sf $(CURDIR)/window_manager/wofi/config ~/.config/wofi/config
	ln -sf $(CURDIR)/window_manager/wofi/style.css ~/.config/wofi/style.css
	cp -af $(CURDIR)/window_manager/systemd/wallpaper.service ~/.config/systemd/user/wallpaper.service
	cp -af $(CURDIR)/window_manager/systemd/wallpaper.timer ~/.config/systemd/user/wallpaper.timer
	cp -af $(CURDIR)/window_manager/systemd/trash.service ~/.config/systemd/user/trash.service
	cp -af $(CURDIR)/window_manager/systemd/trash.timer ~/.config/systemd/user/trash.timer
	bash window_manager/pipewire/config.sh

test:
	cd utilities/ && python -m unittest ffmeta_test
