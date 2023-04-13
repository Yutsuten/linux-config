.PHONY: alacritty fish git mpv neovim nnn utilities system_utilities wm test

bold := $(shell tput bold)
reset := $(shell tput sgr0)

all: alacritty fish git mpv neovim nnn utilities wm
	@echo '${bold}Done!${reset}'
	@echo ' Install system utilities with: `sudo make system_utilities`'

alacritty:
	@echo '${bold}>> Alacritty settings <<${reset}'
	mkdir -p ~/.config/alacritty
	ln -sf $(CURDIR)/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

fish:
	@echo '${bold}>> Fish settings <<${reset}'
	rm -rf ~/.config/fish/config.fish
	ln -sf $(CURDIR)/fish/config.fish ~/.config/fish/config.fish
	ln -sf $(CURDIR)/fish/sway.fish ~/.config/fish/conf.d/sway.fish
	ln -sf $(CURDIR)/fish/functions/aurupdate.fish ~/.config/fish/functions/aurupdate.fish
	ln -sf $(CURDIR)/fish/functions/fish_prompt.fish ~/.config/fish/functions/fish_prompt.fish
	ln -sf $(CURDIR)/fish/functions/ls.fish ~/.config/fish/functions/ls.fish
	ln -sf $(CURDIR)/fish/functions/lo.fish ~/.config/fish/functions/lo.fish
	ln -sf $(CURDIR)/fish/functions/ll.fish ~/.config/fish/functions/ll.fish
	ln -sf $(CURDIR)/fish/functions/nnn.fish ~/.config/fish/functions/nnn.fish
	ln -sf $(CURDIR)/fish/functions/passgen.fish ~/.config/fish/functions/passgen.fish
	ln -sf $(CURDIR)/fish/functions/record.fish ~/.config/fish/functions/record.fish
	ln -sf $(CURDIR)/fish/functions/clicker.fish ~/.config/fish/functions/clicker.fish

git:
	@echo '${bold}>> Git settings <<${reset}'
	git config --global core.excludesfile $(CURDIR)/git/gitignore
	git config --global core.pager 'less -SXF'
	git config --global core.editor 'nvim'

mpv:
	@echo '${bold}>> MPV settings <<${reset}'
	mkdir -p ~/.config/mpv/script-opts
	ln -sf $(CURDIR)/mpv/mpv.conf ~/.config/mpv/mpv.conf
	ln -sf $(CURDIR)/mpv/input.conf ~/.config/mpv/input.conf
	ln -sf $(CURDIR)/mpv/uosc.conf ~/.config/mpv/script-opts/uosc.conf

neovim:
	@echo '${bold}>> Neovim settings <<${reset}'
	rm -f ~/.config/nvim/init.vim ~/.config/nvim/*
	rm -rf ~/.local/share/nvim/site/*
	mkdir -p ~/.config/nvim ~/.local/share/nvim/site/pack/all
	ln -sf $(CURDIR)/neovim/init.vim ~/.config/nvim/init.vim
	ln -sf $(CURDIR)/neovim/ginit.vim ~/.config/nvim/ginit.vim
	ln -snf $(CURDIR)/neovim/pack ~/.local/share/nvim/site/pack/all/start
	ln -snf $(CURDIR)/neovim/plugin ~/.local/share/nvim/site/plugin
	ln -snf $(CURDIR)/neovim/ftplugin ~/.local/share/nvim/site/ftplugin
	ln -snf $(CURDIR)/neovim/doc ~/.local/share/nvim/site/doc

nnn:
	@echo '${bold}>> Nnn plugins <<${reset}'
	rm -rf ~/.config/nnn/plugins
	ln -sf $(CURDIR)/nnn/plugins ~/.config/nnn/plugins

utilities:
	@echo '${bold}>> Utilities <<${reset}'
	mkdir -p ~/.local/bin
	ln -sf $(CURDIR)/utilities/bkptool.sh ~/.local/bin/bkptool
	ln -sf $(CURDIR)/utilities/ffmeta.py ~/.local/bin/ffmeta

system_utilities:
	cp -af $(CURDIR)/utilities/screenshot.sh /usr/local/bin/screenshot
	cp -af $(CURDIR)/utilities/openweather.py /usr/local/bin/openweather
	cp -af $(CURDIR)/utilities/wallpaper.py /usr/local/bin/wallpaper
	cp -af $(CURDIR)/utilities/system.sh /usr/local/bin/system

wm:
	@echo '${bold}>> Window manager settings <<${reset}'
	mkdir -p ~/.config/sway ~/.config/swaylock ~/.config/waybar ~/.config/dunst ~/.config/gtk-3.0 ~/.config/systemd/user ~/.config/wofi/
	ln -sf $(CURDIR)/window_manager/sway.conf ~/.config/sway/config
	ln -sf $(CURDIR)/window_manager/swaylock.conf ~/.config/swaylock/config
	ln -sf $(CURDIR)/window_manager/waybar/config.json ~/.config/waybar/config
	ln -sf $(CURDIR)/window_manager/waybar/style.css ~/.config/waybar/style.css
	ln -sf $(CURDIR)/window_manager/dunstrc.conf ~/.config/dunst/dunstrc
	ln -sf $(CURDIR)/window_manager/gtk/gtk2.ini ~/.gtkrc-2.0
	ln -sf $(CURDIR)/window_manager/gtk/gtk3.ini ~/.config/gtk-3.0/settings.ini
	ln -sf $(CURDIR)/window_manager/wofi/config ~/.config/wofi/config
	ln -sf $(CURDIR)/window_manager/wofi/style.css ~/.config/wofi/style.css
	cp -af $(CURDIR)/window_manager/wallpaper.service ~/.config/systemd/user/wallpaper.service
	cp -af $(CURDIR)/window_manager/wallpaper.timer ~/.config/systemd/user/wallpaper.timer

test:
	cd utilities/ && python -m unittest ffmeta_test
