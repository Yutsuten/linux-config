all: links

links: link_git link_lint link_nvim link_zsh
	@echo 'Done.'

link_git:
	@echo '## Git links'
	ln -sf $(CURDIR)/git/global.gitignore ~/.gitignore
	git config --global core.excludesfile ~/.gitignore
	git config --global core.pager 'less -S'
	git config --global core.editor 'nvim'

link_lint:
	@echo '## Lint links'
	mkdir -p ~/.config
	ln -sf $(CURDIR)/lint/flake8 ~/.config/flake8
	ln -sf $(CURDIR)/lint/pylint ~/.config/pylintrc
	ln -sf $(CURDIR)/lint/jshint.json ~/.jshintrc

link_nvim:
	@echo '## Neovim links'
	mkdir -p ~/.config/nvim
	rm -f ~/.config/nvim/init.vim
	ln -sf $(CURDIR)/nvim/init.vim ~/.config/nvim/init.vim
	ln -sf $(CURDIR)/nvim/nmake ~/.local/bin/nmake
	rm -rf ~/.local/share/nvim/site/pack ~/.local/share/nvim/site/plugin
	mkdir -p ~/.local/share/nvim/site/pack/all
	ln -snf $(CURDIR)/nvim/pack ~/.local/share/nvim/site/pack/all/start
	ln -snf $(CURDIR)/nvim/plugin ~/.local/share/nvim/site/plugin

link_zsh:
	@echo '## Zsh links'
	ln -sf $(CURDIR)/zsh/aliases.zsh ~/.oh-my-zsh/custom/aliases.zsh
	ln -sf $(CURDIR)/zsh/yutsuten.zsh-theme ~/.oh-my-zsh/custom/themes/yutsuten.zsh-theme
	sed -i \
	  -e 's/^ZSH_THEME=.*/ZSH_THEME="yutsuten"/' \
	  -e 's/^plugins=.*/plugins=(git virtualenv)/' ~/.zshrc
