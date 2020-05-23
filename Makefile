config: config_git config_lint config_nvim config_zsh

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

config_nvim:
	@echo '## Neovim configuration'
	rm -f ~/.config/nvim/init.vim
	rm -rf ~/.local/share/nvim/site/*
	mkdir -p ~/.config/nvim
	mkdir -p ~/.local/share/nvim/site/pack/all
	ln -sf $(CURDIR)/nvim/init.vim ~/.config/nvim/init.vim
	ln -sf $(CURDIR)/nvim/nmake ~/.local/bin/nmake
	ln -snf $(CURDIR)/nvim/pack ~/.local/share/nvim/site/pack/all/start
	ln -snf $(CURDIR)/nvim/plugin ~/.local/share/nvim/site/plugin
	ln -snf $(CURDIR)/nvim/ftplugin ~/.local/share/nvim/site/ftplugin

config_zsh:
	@echo '## Zsh configuration'
	ln -sf $(CURDIR)/zsh/aliases.zsh ~/.oh-my-zsh/custom/aliases.zsh
	ln -sf $(CURDIR)/zsh/yutsuten.zsh-theme ~/.oh-my-zsh/custom/themes/yutsuten.zsh-theme
	sed -i \
	  -e 's/^ZSH_THEME=.*/ZSH_THEME="yutsuten"/' \
	  -e 's/^plugins=.*/plugins=(git virtualenv ssh-agent)/' ~/.zshrc

arch:
	@echo '## Arch Linux dependencies'
	sudo pacman -S flake8 python-pylint eslint yarn
	yarn global add htmlhint jshint
	@echo "Add $$(yarn global dir) to your PATH!"

ubuntu:
	@echo '## Ubuntu dependencies'
	sudo apt install flake8 pylint yarn
	yarn global add eslint htmlhint jshint
	@echo "Add $$(yarn global dir) to your PATH!"
