all:
	@echo 'Usage: make links'

links: link_bash link_git link_tmux link_vim
	@echo 'Done.'

link_bash:
	@echo '## Bash links'
	$(eval LINE='source $(CURDIR)/bash/mylibrary.sh')
	grep -qF -- ${LINE} ~/.bashrc || echo ${LINE} >> ~/.bashrc
	$(eval LINE='source $(CURDIR)/bash/bash.sh')
	grep -qF -- ${LINE} ~/.bashrc || echo ${LINE} >> ~/.bashrc
	ln -sf $(CURDIR)/bash/dircolors-solarized/dircolors.ansi-dark ~/.dircolors

link_git:
	@echo '## Git links'
	ln -sf $(CURDIR)/git/global.gitignore ~/.gitignore
	git config --global core.excludesfile ~/.gitignore

link_tmux:
	@echo '## Tmux links'
	ln -snf $(CURDIR)/tmux ~/.tmux
	ln -sf ${HOME}/.tmux/tmux.conf ~/.tmux.conf

link_vim:
	@echo '## Vim links'
	ln -snf $(CURDIR)/vim ~/.vim
