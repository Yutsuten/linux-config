config: config_git config_lint config_neovim config_zsh config_desktop

config_git:
	@echo '## Git configuration'
	ln -sf $(CURDIR)/git/global.gitignore ~/.gitignore
	git config --global core.excludesfile ~/.gitignore
	git config --global core.pager 'less -SXF'
	git config --global core.editor 'nvim'

config_lint:
	@echo '## Lint configuration'
	mkdir -p ~/.config
	ln -sf $(CURDIR)/lint/flake8 ~/.config/flake8
	ln -sf $(CURDIR)/lint/pylint ~/.config/pylintrc
	ln -sf $(CURDIR)/lint/jshint.json ~/.jshintrc

config_neovim:
	@echo '## Neovim configuration'
	rm -f ~/.config/nvim/init.vim
	rm -rf ~/.local/share/nvim/site/*
	mkdir -p ~/.config/nvim ~/.local/share/nvim/site/pack/all
	ln -sf $(CURDIR)/neovim/init.vim ~/.config/nvim/init.vim
	ln -sf $(CURDIR)/neovim/ginit.vim ~/.config/nvim/ginit.vim
	ln -snf $(CURDIR)/neovim/pack ~/.local/share/nvim/site/pack/all/start
	ln -snf $(CURDIR)/neovim/plugin ~/.local/share/nvim/site/plugin
	ln -snf $(CURDIR)/neovim/ftplugin ~/.local/share/nvim/site/ftplugin

config_zsh:
	@echo '## Zsh configuration'
	ln -sf $(CURDIR)/zsh/dev_aliases.zsh ~/.oh-my-zsh/custom/dev_aliases.zsh
	ln -sf $(CURDIR)/zsh/yutsuten.zsh-theme ~/.oh-my-zsh/custom/themes/yutsuten.zsh-theme
	sed -i \
	  -e 's/^ZSH_THEME=.*/ZSH_THEME="yutsuten"/' \
	  -e 's/^plugins=.*/plugins=(git virtualenv ssh-agent)/' ~/.zshrc

config_desktop:
	@echo '## Desktop configuration'
	mkdir -p ~/.config/i3 ~/.config/i3status ~/.config/picom ~/.config/dunst ~/.config/kitty
	ln -sf $(CURDIR)/desktop/i3.conf ~/.config/i3/config
	ln -sf $(CURDIR)/desktop/i3status.conf ~/.config/i3status/config
	ln -sf $(CURDIR)/desktop/picom.conf ~/.config/picom/picom.conf
	ln -sf $(CURDIR)/desktop/dunstrc ~/.config/dunst/dunstrc
	ln -sf $(CURDIR)/desktop/Xresources ~/.Xresources
	ln -sf $(CURDIR)/desktop/kitty.conf ~/.config/kitty/kitty.conf
	ln -sf $(CURDIR)/desktop/xprofile ~/.xprofile

arch:
	@echo '## Arch Linux dependencies'
	sudo pacman -S flake8 python-pylint python-language-server eslint yarn
	yarn global add htmlhint jshint
	@echo "Add $$(yarn global dir) to your PATH!"

ubuntu:
	@echo '## Ubuntu dependencies'
	sudo apt install flake8 pylint yarn
	yarn global add eslint htmlhint jshint
	@echo "Add $$(yarn global dir) to your PATH!"

homebrew:
	@echo '## Homebrew dependencies'
	brew install python flake8 pylint
	pip3 install --user python-language-server
