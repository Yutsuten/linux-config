.PHONY: all system desktop git linters neovim scripts zsh

all: desktop git linters neovim scripts zsh
	@echo 'Checking differences in pam_environment...'
	@diff --color=always -u ~/.pam_environment desktop/pam_environment || true
	@echo
	@echo 'Done!'

system:
	@echo '>> System configuration <<'
	cp -p $(CURDIR)/system/environment /etc/environment
	cp -p $(CURDIR)/system/wallpaper.service /etc/systemd/system/wallpaper.service
	cp -p $(CURDIR)/system/wallpaper.timer /etc/systemd/system/wallpaper.timer
	cp -p $(CURDIR)/system/openweather.service /etc/systemd/system/openweather.service
	cp -p $(CURDIR)/system/openweather.timer /etc/systemd/system/openweather.timer
	@echo

desktop:
	@echo '>> Desktop configuration <<'
	mkdir -p ~/.config/i3 ~/.config/i3status ~/.config/picom ~/.config/dunst ~/.config/kitty
	cp -pn $(CURDIR)/desktop/pam_environment ~/.pam_environment
	ln -sf $(CURDIR)/desktop/i3.conf ~/.config/i3/config
	ln -sf $(CURDIR)/desktop/i3status.conf ~/.config/i3status/config
	ln -sf $(CURDIR)/desktop/picom.conf ~/.config/picom/picom.conf
	ln -sf $(CURDIR)/desktop/dunstrc ~/.config/dunst/dunstrc
	ln -sf $(CURDIR)/desktop/kitty.conf ~/.config/kitty/kitty.conf
	@echo

git:
	@echo '>> Git configuration <<'
	ln -sf $(CURDIR)/git/global.gitignore ~/.gitignore
	git config --global core.excludesfile ~/.gitignore
	git config --global core.pager 'less -SXF'
	git config --global core.editor 'nvim'
	@echo

linters:
	@echo '>> Linters configuration <<'
	mkdir -p ~/.config
	ln -sf $(CURDIR)/linters/flake8 ~/.config/flake8
	ln -sf $(CURDIR)/linters/pylint ~/.config/pylintrc
	ln -sf $(CURDIR)/linters/jshint.json ~/.jshintrc
	@echo

neovim:
	@echo '>> Neovim configuration <<'
	rm -f ~/.config/nvim/init.vim
	rm -rf ~/.local/share/nvim/site/*
	mkdir -p ~/.config/nvim ~/.local/share/nvim/site/pack/all
	ln -sf $(CURDIR)/neovim/init.vim ~/.config/nvim/init.vim
	ln -sf $(CURDIR)/neovim/ginit.vim ~/.config/nvim/ginit.vim
	ln -snf $(CURDIR)/neovim/pack ~/.local/share/nvim/site/pack/all/start
	ln -snf $(CURDIR)/neovim/plugin ~/.local/share/nvim/site/plugin
	ln -snf $(CURDIR)/neovim/ftplugin ~/.local/share/nvim/site/ftplugin
	@echo

scripts:
	@echo '>> Scripts configuration <<'
	mkdir -p ~/.local/bin ~/.task/hooks
	ln -sf $(CURDIR)/scripts/bkp_tool.sh ~/.local/bin/bkp_tool
	ln -sf $(CURDIR)/scripts/gamemode.sh ~/.local/bin/gamemode
	ln -sf $(CURDIR)/scripts/tw-fellow-hook.sh ~/.task/hooks/on-exit-fellow-taskdone.sh
	@echo

zsh:
	@echo '>> Zsh configuration <<'
	rm -f ~/.zshrc
	ln -sf $(CURDIR)/zsh/run_commands.zsh ~/.zshrc
	ln -sf $(CURDIR)/zsh/commands.zsh ~/.oh-my-zsh/custom/commands.zsh
	ln -sf $(CURDIR)/zsh/aliases.zsh ~/.oh-my-zsh/custom/aliases.zsh
	ln -sf $(CURDIR)/zsh/yutsuten.zsh ~/.oh-my-zsh/custom/themes/yutsuten.zsh-theme
	ln -snf $(CURDIR)/zsh/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	@echo
