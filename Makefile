.PHONY: alacritty environment fish git linters neovim nnn taskwarrior wm

bold := $(shell tput bold)
reset := $(shell tput sgr0)

all: alacritty environment fish git linters neovim nnn taskwarrior wm
	@echo '${bold}Done!${reset}'

alacritty:
	@echo '${bold}>> Alacritty settings <<${reset}'
	mkdir -p ~/.config/alacritty
	ln -sf $(CURDIR)/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

environment:
	@echo '${bold}>> Environment settings <<${reset}'
	@echo '⚠️ Append the contents of "$(CURDIR)/environment/environment" into /etc/environment'
	mkdir -p ~/.local/bin
	ln -sf $(CURDIR)/environment/bkp_tool.sh ~/.local/bin/bkp_tool

fish:
	@echo '${bold}>> Fish settings <<${reset}'
	rm -rf ~/.config/fish/config.fish
	ln -sf $(CURDIR)/fish/config.fish ~/.config/fish/config.fish
	ln -sf $(CURDIR)/fish/sway.fish ~/.config/fish/conf.d/sway.fish
	ln -sf $(CURDIR)/fish/functions/aurupdate.fish ~/.config/fish/functions/aurupdate.fish
	ln -sf $(CURDIR)/fish/functions/fish_prompt.fish ~/.config/fish/functions/fish_prompt.fish
	ln -sf $(CURDIR)/fish/functions/ll.fish ~/.config/fish/functions/ll.fish
	ln -sf $(CURDIR)/fish/functions/nnn.fish ~/.config/fish/functions/nnn.fish
	ln -sf $(CURDIR)/fish/functions/passgen.fish ~/.config/fish/functions/passgen.fish
	ln -sf $(CURDIR)/fish/functions/record.fish ~/.config/fish/functions/record.fish
	ln -sf $(CURDIR)/fish/functions/clicker.fish ~/.config/fish/functions/clicker.fish

git:
	@echo '${bold}>> Git settings <<${reset}'
	git config --global core.excludesfile $(CURDIR)/git/gitignore
	git config --global core.pager 'less -SXF'
	git config --global core.editor 'nvim'

neovim:
	@echo '${bold}>> Neovim settings <<${reset}'
	rm -f ~/.config/nvim/init.vim ~/.config/nvim/*
	rm -rf ~/.local/share/nvim/site/*
	mkdir -p ~/.config/nvim ~/.local/share/nvim/site/pack/all
	ln -sf $(CURDIR)/neovim/init.vim ~/.config/nvim/init.vim
	ln -sf $(CURDIR)/neovim/ginit.vim ~/.config/nvim/ginit.vim
	ln -snf $(CURDIR)/neovim/pack ~/.local/share/nvim/site/pack/all/start
	ln -snf $(CURDIR)/neovim/plugin ~/.local/share/nvim/site/plugin
	ln -snf $(CURDIR)/neovim/ftplugin ~/.local/share/nvim/site/ftplugin
	ln -snf $(CURDIR)/neovim/doc ~/.local/share/nvim/site/doc

nnn:
	@echo '${bold}>> Nnn plugins <<${reset}'
	rm -rf ~/.config/nnn/plugins
	ln -sf $(CURDIR)/nnn/plugins ~/.config/nnn/plugins

taskwarrior:
	@echo '${bold}>> Scripts symbolic links <<${reset}'
	mkdir -p ~/.task/hooks
	ln -sf $(CURDIR)/taskwarrior/fellow-hook.sh ~/.task/hooks/on-exit-fellow-taskdone.sh

wm:
	@echo '${bold}>> Window manager settings <<${reset}'
	mkdir -p ~/.config/sway ~/.config/waybar ~/.config/dunst ~/.config/gtk-3.0 ~/.config/systemd/user
	ln -sf $(CURDIR)/window_manager/sway.conf ~/.config/sway/config
	ln -sf $(CURDIR)/window_manager/waybar/config.json ~/.config/waybar/config
	ln -sf $(CURDIR)/window_manager/waybar/style.css ~/.config/waybar/style.css
	ln -sf $(CURDIR)/window_manager/dunstrc.conf ~/.config/dunst/dunstrc
	ln -sf $(CURDIR)/window_manager/gtk/gtk2.ini ~/.gtkrc-2.0
	ln -sf $(CURDIR)/window_manager/gtk/gtk3.ini ~/.config/gtk-3.0/settings.ini
	cp -af $(CURDIR)/window_manager/wallpaper.service ~/.config/systemd/user/wallpaper.service
	cp -af $(CURDIR)/window_manager/wallpaper.timer ~/.config/systemd/user/wallpaper.timer

wm_system:
	cp -af $(CURDIR)/window_manager/scripts/screenshot.sh /usr/local/bin/screenshot
	cp -af $(CURDIR)/window_manager/scripts/openweather.py /usr/local/bin/openweather
	cp -af $(CURDIR)/window_manager/scripts/wallpaper.py /usr/local/bin/wallpaper
