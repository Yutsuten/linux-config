all:
	@echo 'Usage: make links'

links: link_bash link_git link_tmux link_vim
	@echo 'Done.'

link_bash:
	@echo '## Bash links'
	echo 'source ~/dev-config/bash/prompt.sh' >> ~/.bashrc
	echo 'PS1="$${USER_PROMPT}"' >> ~/.bashrc

link_git:
	@echo '## Git links'
	ln -sf ${HOME}/dev-config/git/global.gitignore ~/.gitignore
	git config --global core.excludesfile ~/.gitignore

link_tmux:
	@echo '## Tmux links'
	ln -sf ${HOME}/dev-config/tmux/tmux.conf ~/.tmux.conf

link_vim:
	@echo '## Vim links'
	ln -snf ${HOME}/dev-config/vim ~/.vim
