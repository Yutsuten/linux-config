.PHONY: all desktop git linters neovim scripts zsh

all: desktop git linters neovim scripts zsh
	@echo 'Done!'

desktop:
	@echo '>> Desktop configuration <<'
	mkdir -p ~/.config/i3 ~/.config/i3status ~/.config/picom ~/.config/dunst ~/.config/kitty
	ln -sf $(CURDIR)/desktop/pam_environment ~/.pam_environment
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
	ln -sf $(CURDIR)/zsh/misc.zsh ~/.oh-my-zsh/custom/misc.zsh
	ln -sf $(CURDIR)/zsh/aliases.zsh ~/.oh-my-zsh/custom/aliases.zsh
	ln -sf $(CURDIR)/zsh/yutsuten.zsh-theme ~/.oh-my-zsh/custom/themes/yutsuten.zsh-theme
	ln -snf $(CURDIR)/zsh/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	sed -i \
	  -e 's/^ZSH_THEME=.*/ZSH_THEME="yutsuten"/' \
	  -e 's/^plugins=.*/plugins=(git virtualenv ssh-agent zsh-syntax-highlighting)/' \
	  ~/.zshrc
	@echo
