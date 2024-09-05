## Simple setup

When SSHing in a server with no configuration,
and cloning this repository seems to be overkill,
use this small script to download some basic configuration:

```shell
mkdir -p ~/.config/nvim/colors ~/.config/nvim/plugin
curl -Lo ~/.config/nvim/init.vim 'https://raw.githubusercontent.com/Yutsuten/linux-config/main/tools/nvim/init.vim'
curl -Lo ~/.config/nvim/colors/onehalfdark.vim 'https://raw.githubusercontent.com/Yutsuten/linux-config/main/tools/nvim/colors/onehalfdark.vim'
curl -Lo ~/.config/nvim/plugin/colorscheme.vim 'https://raw.githubusercontent.com/Yutsuten/linux-config/main/tools/nvim/plugin/colorscheme.vim'
curl -Lo ~/.config/nvim/plugin/statusline.vim "https://raw.githubusercontent.com/Yutsuten/linux-config/main/tools/nvim/plugin/statusline.vim"
```
