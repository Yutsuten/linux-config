all: links

links: link_bash link_zsh link_git link_tmux link_nvim link_lint
	@echo 'Done.'

link_bash:
	@echo '## Bash links'
	$(eval LINE='source $(CURDIR)/bash/mylibrary.sh')
	grep -qF -- ${LINE} ~/.bashrc || echo ${LINE} >> ~/.bashrc
	$(eval LINE='source $(CURDIR)/bash/bash.sh')
	grep -qF -- ${LINE} ~/.bashrc || echo ${LINE} >> ~/.bashrc
	ln -sf $(CURDIR)/bash/dircolors-solarized/dircolors.ansi-dark ~/.dircolors

link_zsh:
	@echo '## Zsh links'
	ln -sf $(CURDIR)/zsh/aliases.zsh ~/.oh-my-zsh/custom/aliases.zsh
	ln -sf $(CURDIR)/zsh/yutsuten.zsh-theme ~/.oh-my-zsh/custom/themes/yutsuten.zsh-theme
	sed -ie 's/^[[:space:]]*ZSH_THEME=.*/ZSH_THEME="yutsuten"/' ~/.zshrc

link_git:
	@echo '## Git links'
	ln -sf $(CURDIR)/git/global.gitignore ~/.gitignore
	git config --global core.excludesfile ~/.gitignore

link_tmux:
	@echo '## Tmux links'
	ln -snf $(CURDIR)/tmux ~/.tmux
	ln -sf ~/.tmux/tmux.conf ~/.tmux.conf

link_nvim:
	@echo '## Neovim links'
	mkdir -p ~/.config/nvim
	rm -f ~/.config/nvim/init.vim
	ln -sf $(CURDIR)/nvim/init.vim ~/.config/nvim/init.vim
	rm -rf ~/.local/share/nvim/site/pack ~/.local/share/nvim/site/plugin
	mkdir -p ~/.local/share/nvim/site/pack/all
	ln -snf $(CURDIR)/nvim/pack ~/.local/share/nvim/site/pack/all/start
	ln -snf $(CURDIR)/nvim/plugin ~/.local/share/nvim/site/plugin

link_lint:
	@echo '## Lint links'
	mkdir -p ~/.config
	ln -sf $(CURDIR)/lint/flake8 ~/.config/flake8
	ln -sf $(CURDIR)/lint/pylint ~/.config/pylintrc
	ln -sf $(CURDIR)/lint/jshint.json ~/.jshintrc
