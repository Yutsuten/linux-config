.PHONY: user_all system_all user_environment user_desktop user_apps user_linters user_git user_neovim user_zsh user_appentries user_scripts system_env system_settings systemctl_settings

user_all: user_environment user_desktop user_apps user_git user_neovim user_zsh user_linters user_appentries user_scripts
	@echo 'Done!'

system_all: system_env system_settings systemctl_settings
	@echo 'Done!'


user_environment:
	@echo '>> Environment settings <<'
	ln -sf $(CURDIR)/settings/environment/pam_environment ~/.pam_environment
	@echo

user_desktop:
	@echo '>> Desktop settings <<'
	mkdir -p ~/.config/i3 ~/.config/i3status ~/.config/picom ~/.config/dunst
	ln -sf $(CURDIR)/settings/desktop/i3.conf ~/.config/i3/config
	ln -sf $(CURDIR)/settings/desktop/i3status.conf ~/.config/i3status/config
	ln -sf $(CURDIR)/settings/desktop/picom.conf ~/.config/picom/picom.conf
	ln -sf $(CURDIR)/settings/desktop/dunstrc.conf ~/.config/dunst/dunstrc
	@echo

user_apps:
	@echo '>> Application settings <<'
	mkdir -p ~/.config/alacritty
	ln -sf $(CURDIR)/settings/app/alacritty.yml ~/.config/alacritty/alacritty.yml
	ln -sf $(CURDIR)/settings/app/mimeapps.list ~/.config/mimeapps.list
	@echo

user_git:
	@echo '>> Git settings <<'
	ln -sf $(CURDIR)/settings/app/gitignore ~/.gitignore
	git config --global core.excludesfile ~/.gitignore
	git config --global core.pager 'less -SXF'
	git config --global core.editor 'nvim'
	@echo

user_neovim:
	@echo '>> Neovim settings <<'
	rm -f ~/.config/nvim/init.vim
	rm -rf ~/.local/share/nvim/site/*
	mkdir -p ~/.config/nvim ~/.local/share/nvim/site/pack/all
	ln -sf $(CURDIR)/neovim/init.vim ~/.config/nvim/init.vim
	ln -sf $(CURDIR)/neovim/ginit.vim ~/.config/nvim/ginit.vim
	ln -snf $(CURDIR)/neovim/pack ~/.local/share/nvim/site/pack/all/start
	ln -snf $(CURDIR)/neovim/plugin ~/.local/share/nvim/site/plugin
	ln -snf $(CURDIR)/neovim/ftplugin ~/.local/share/nvim/site/ftplugin
	ln -snf $(CURDIR)/neovim/doc ~/.local/share/nvim/site/doc
	@echo

user_zsh:
	@echo '>> Zsh settings <<'
	rm -f ~/.zshrc
	ln -sf $(CURDIR)/zsh/run_commands.zsh ~/.zshrc
	@echo

user_linters:
	@echo '>> Linter settings <<'
	mkdir -p ~/.config
	ln -sf $(CURDIR)/settings/linter/flake8.conf ~/.config/flake8
	ln -sf $(CURDIR)/settings/linter/pylint.conf ~/.config/pylintrc
	ln -sf $(CURDIR)/settings/linter/jshint.json ~/.jshintrc
	@echo

user_appentries:
	@echo '>> Application entries <<'
	mkdir -p ~/.local/share/applications
	ln -sf $(CURDIR)/settings/app_entry/osu.desktop ~/.local/share/applications/osu.desktop
	ln -sf $(CURDIR)/settings/app_entry/sxiv.desktop ~/.local/share/applications/sxiv.desktop
	ln -sf $(CURDIR)/settings/app_entry/anki.desktop ~/.local/share/applications/anki.desktop
	@echo

user_scripts:
	@echo '>> Scripts symbolic links <<'
	mkdir -p ~/.local/bin ~/.task/hooks
	ln -sf $(CURDIR)/scripts/bkp_tool.sh ~/.local/bin/bkp_tool
	ln -sf $(CURDIR)/scripts/gamemode.sh ~/.local/bin/gamemode
	ln -sf $(CURDIR)/scripts/tw-fellow-hook.sh ~/.task/hooks/on-exit-fellow-taskdone.sh
	@echo

system_env:
	@echo '>> System environment settings <<'
	cp -p $(CURDIR)/settings/environment/environment /etc/environment
	@echo

system_settings:
	@echo '>> System settings <<'
	cp -p $(CURDIR)/settings/system/slick-greeter.conf /etc/lightdm/slick-greeter.conf
	cp -p $(CURDIR)/settings/system/wacom-options.conf /etc/X11/xorg.conf.d/72-wacom-options.conf
	@echo

systemctl_settings:
	@echo '>> Systemctl settings <<'
	cp -p $(CURDIR)/settings/systemctl/wallpaper.service /etc/systemd/system/wallpaper.service
	cp -p $(CURDIR)/settings/systemctl/wallpaper.timer /etc/systemd/system/wallpaper.timer
	cp -p $(CURDIR)/settings/systemctl/openweather.service /etc/systemd/system/openweather.service
	cp -p $(CURDIR)/settings/systemctl/openweather.timer /etc/systemd/system/openweather.timer
	@echo
