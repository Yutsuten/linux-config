.PHONY: user_all system_all user_environment user_desktop user_apps user_git user_neovim user_nnn user_zsh user_linters user_appentries user_scripts system_env system_settings systemctl_settings

bold := $(shell tput bold)
reset := $(shell tput sgr0)

user_all: user_environment user_desktop user_apps user_git user_neovim user_nnn user_zsh user_linters user_appentries user_scripts
	@echo '${bold}Done!${reset}'

system_all: system_env system_settings systemctl_settings
	@echo '${bold}Done!${reset}'

user_environment:
	@echo '${bold}>> Environment settings <<${reset}'
	ln -sf $(CURDIR)/settings/environment/pam_environment ~/.pam_environment

user_desktop:
	@echo '${bold}>> Desktop settings <<${reset}'
	mkdir -p ~/.config/i3 ~/.config/i3blocks ~/.config/picom ~/.config/dunst
	ln -sf $(CURDIR)/settings/desktop/i3.conf ~/.config/i3/config
	ln -sf $(CURDIR)/settings/desktop/i3blocks.conf ~/.config/i3blocks/config
	ln -sf $(CURDIR)/settings/desktop/picom.conf ~/.config/picom/picom.conf
	ln -sf $(CURDIR)/settings/desktop/dunstrc.conf ~/.config/dunst/dunstrc

user_apps:
	@echo '${bold}>> Application settings <<${reset}'
	mkdir -p ~/.config/alacritty
	ln -sf $(CURDIR)/settings/app/alacritty.yml ~/.config/alacritty/alacritty.yml
	ln -sf $(CURDIR)/settings/app/mimeapps.list ~/.config/mimeapps.list
	ln -sf $(CURDIR)/settings/app/Xresources ~/.Xresources

user_git:
	@echo '${bold}>> Git settings <<${reset}'
	ln -sf $(CURDIR)/settings/app/gitignore ~/.gitignore
	git config --global core.excludesfile ~/.gitignore
	git config --global core.pager 'less -SXF'
	git config --global core.editor 'nvim'

user_neovim:
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

user_nnn:
	@echo '${bold}>> Nnn plugins <<${reset}'
	rm -rf ~/.config/nnn/plugins
	ln -sf $(CURDIR)/nnn/plugins ~/.config/nnn/plugins

user_zsh:
	@echo '${bold}>> Zsh settings <<${reset}'
	rm -f ~/.zshrc
	ln -sf $(CURDIR)/zsh/run_commands.zsh ~/.zshrc

user_linters:
	@echo '${bold}>> Linter settings <<${reset}'
	mkdir -p ~/.config
	ln -sf $(CURDIR)/settings/linter/flake8.conf ~/.config/flake8
	ln -sf $(CURDIR)/settings/linter/pylint.conf ~/.config/pylintrc
	ln -sf $(CURDIR)/settings/linter/jshint.json ~/.jshintrc

user_appentries:
	@echo '${bold}>> Application entries <<${reset}'
	mkdir -p ~/.local/share/applications
	ln -sf $(CURDIR)/settings/app_entry/*.desktop ~/.local/share/applications

user_scripts:
	@echo '${bold}>> Scripts symbolic links <<${reset}'
	mkdir -p ~/.local/bin ~/.task/hooks ~/.config/sxiv/exec
	ln -sf $(CURDIR)/scripts/bkp_tool.sh ~/.local/bin/bkp_tool
	ln -sf $(CURDIR)/scripts/gamemode.sh ~/.local/bin/gamemode
	ln -sf $(CURDIR)/scripts/nsxiv.sh ~/.local/bin/nsxiv
	ln -sf $(CURDIR)/scripts/screenshot.sh ~/.local/bin/screenshot
	ln -sf $(CURDIR)/scripts/wallpaper.py ~/.local/bin/wallpaper
	ln -sf $(CURDIR)/scripts/sxiv-image-info.sh ~/.config/sxiv/exec/image-info
	ln -sf $(CURDIR)/scripts/tw-fellow-hook.sh ~/.task/hooks/on-exit-fellow-taskdone.sh
	xrdb ~/.Xresources

system_settings:
	@echo '${bold}>> System settings <<${reset}'
	cp -p $(CURDIR)/settings/system/slick-greeter.conf /etc/lightdm/slick-greeter.conf
	cp -p $(CURDIR)/settings/system/lightdm-display-setup.sh /etc/lightdm/lightdm-display-setup.sh
	cp -p $(CURDIR)/settings/system/wacom-options.conf /etc/X11/xorg.conf.d/72-wacom-options.conf

systemctl_settings:
	@echo '${bold}>> Systemctl settings <<${reset}'
	cp -p $(CURDIR)/settings/systemctl/wallpaper.service /etc/systemd/system/wallpaper.service
	cp -p $(CURDIR)/settings/systemctl/wallpaper.timer /etc/systemd/system/wallpaper.timer

system_env:
	@echo '${bold}>> System environment settings <<${reset}'
	@echo 'Copy the contents below into /etc/environment'
	@cat $(CURDIR)/settings/environment/environment
