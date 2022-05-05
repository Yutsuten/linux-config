.PHONY: wm user_apps git neovim nnn fish linters appentries scripts environment

bold := $(shell tput bold)
reset := $(shell tput sgr0)

all: wm user_apps git neovim nnn fish linters appentries scripts environment
	@echo '${bold}Done!${reset}'

wm:
	@echo '${bold}>> Window manager settings <<${reset}'
	mkdir -p ~/.config/sway ~/.config/i3blocks ~/.config/dunst ~/.config/systemd/user
	ln -sf $(CURDIR)/window_manager/sway.conf ~/.config/sway/config
	ln -sf $(CURDIR)/window_manager/i3blocks.conf ~/.config/i3blocks/config
	ln -sf $(CURDIR)/window_manager/dunstrc.conf ~/.config/dunst/dunstrc
	ln -sf $(CURDIR)/window_manager/wallpaper.service ~/.config/systemd/user/wallpaper.service
	ln -sf $(CURDIR)/window_manager/wallpaper.timer ~/.config/systemd/user/wallpaper.timer

user_apps:
	@echo '${bold}>> Application settings <<${reset}'
	mkdir -p ~/.config/alacritty
	ln -sf $(CURDIR)/settings/app/alacritty.yml ~/.config/alacritty/alacritty.yml
	ln -sf $(CURDIR)/settings/app/mimeapps.list ~/.config/mimeapps.list

git:
	@echo '${bold}>> Git settings <<${reset}'
	ln -sf $(CURDIR)/settings/app/gitignore ~/.gitignore
	git config --global core.excludesfile ~/.gitignore
	git config --global core.pager 'less -SXF'
	git config --global core.editor 'nvim'

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

fish:
	@echo '${bold}>> Fish settings <<${reset}'
	rm -f ~/.config/fish/config.fish
	ln -sf $(CURDIR)/fish/config.fish ~/.config/fish/config.fish

linters:
	@echo '${bold}>> Linter settings <<${reset}'
	mkdir -p ~/.config
	ln -sf $(CURDIR)/settings/linter/flake8.conf ~/.config/flake8
	ln -sf $(CURDIR)/settings/linter/pylint.conf ~/.config/pylintrc
	ln -sf $(CURDIR)/settings/linter/jshint.json ~/.jshintrc

appentries:
	@echo '${bold}>> Application entries <<${reset}'
	mkdir -p ~/.local/share/applications
	ln -sf $(CURDIR)/settings/app_entry/*.desktop ~/.local/share/applications

scripts:
	@echo '${bold}>> Scripts symbolic links <<${reset}'
	mkdir -p ~/.local/bin ~/.task/hooks
	ln -sf $(CURDIR)/scripts/bkp_tool.sh ~/.local/bin/bkp_tool
	ln -sf $(CURDIR)/scripts/screenshot.sh ~/.local/bin/screenshot
	ln -sf $(CURDIR)/scripts/wallpaper.py ~/.local/bin/wallpaper
	ln -sf $(CURDIR)/scripts/tw-fellow-hook.sh ~/.task/hooks/on-exit-fellow-taskdone.sh

environment:
	@echo '${bold}>> System environment <<${reset}'
	@echo 'Append the contents below into /etc/environment'
	@cat $(CURDIR)/settings/environment/environment
