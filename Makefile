.PHONY: alacritty environment fish git linters neovim nnn taskwarrior wm

bold := $(shell tput bold)
reset := $(shell tput sgr0)

all: alacritty environment fish git linters neovim nnn taskwarrior wm
	@echo '${bold}Done!${reset}'

alacritty:
	@echo '${bold}>> Alacritty settings <<${reset}'
	mkdir -p ~/.config/alacritty
	ln -sf $(CURDIR)/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

environment:
	@echo '${bold}>> Environment settings <<${reset}'
	@echo '⚠️ Append the contents of "$(CURDIR)/environment/environment" into /etc/environment'
	mkdir -p ~/.local/bin
	ln -sf $(CURDIR)/environment/bkp_tool.sh ~/.local/bin/bkp_tool

fish:
	@echo '${bold}>> Fish settings <<${reset}'
	rm -rf ~/.config/fish/config.fish ~/.config/fish/functions
	ln -sf $(CURDIR)/fish/config.fish ~/.config/fish/config.fish
	ln -sf $(CURDIR)/fish/sway.fish ~/.config/fish/conf.d/sway.fish
	ln -sf $(CURDIR)/fish/functions ~/.config/fish/functions

git:
	@echo '${bold}>> Git settings <<${reset}'
	git config --global core.excludesfile $(CURDIR)/git/gitignore
	git config --global core.pager 'less -SXF'
	git config --global core.editor 'nvim'

linters:
	@echo '${bold}>> Linter settings <<${reset}'
	mkdir -p ~/.config
	ln -sf $(CURDIR)/linters/flake8.conf ~/.config/flake8
	ln -sf $(CURDIR)/linters/pylint.conf ~/.config/pylintrc
	ln -sf $(CURDIR)/linters/jshint.json ~/.jshintrc

neovim:
	@echo '${bold}>> Neovim settings <<${reset}'
	rm -f ~/.config/nvim/init.vim
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
	ln -sf $(CURDIR)/nnn/mimeapps.list ~/.config/mimeapps.list

taskwarrior:
	@echo '${bold}>> Scripts symbolic links <<${reset}'
	mkdir -p ~/.task/hooks
	ln -sf $(CURDIR)/taskwarrior/tw-fellow-hook.sh ~/.task/hooks/on-exit-fellow-taskdone.sh

wm:
	@echo '${bold}>> Window manager settings <<${reset}'
	mkdir -p ~/.config/sway ~/.config/i3blocks ~/.config/dunst ~/.config/systemd/user ~/.local/bin
	ln -sf $(CURDIR)/window_manager/sway.conf ~/.config/sway/config
	ln -sf $(CURDIR)/window_manager/i3blocks.conf ~/.config/i3blocks/config
	ln -sf $(CURDIR)/window_manager/dunstrc.conf ~/.config/dunst/dunstrc
	ln -sf $(CURDIR)/window_manager/gtk3.ini ~/.config/gtk-3.0/settings.ini
	ln -sf $(CURDIR)/window_manager/scripts/openweather.py ~/.local/bin/openweather
	ln -sf $(CURDIR)/window_manager/scripts/screenshot.sh ~/.local/bin/screenshot
	ln -sf $(CURDIR)/window_manager/scripts/wallpaper.py ~/.local/bin/wallpaper
	ln -sf $(CURDIR)/window_manager/launchers/*.desktop ~/.local/share/applications
	cp -af $(CURDIR)/window_manager/wallpaper.service ~/.config/systemd/user/wallpaper.service
	cp -af $(CURDIR)/window_manager/wallpaper.timer ~/.config/systemd/user/wallpaper.timer
