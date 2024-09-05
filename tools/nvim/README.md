## Simple setup

If SSHing in a server with no configuration,
and cloning this repository seems to be overkill,
use this small script to download `init.vim`:

```shell
mkdir -p ~/.config/nvim/plugin
curl -Lso ~/.config/nvim/init.vim 'https://raw.githubusercontent.com/Yutsuten/linux-config/main/tools/nvim/init.vim'
curl -Lso ~/.config/nvim/plugin/statusline.vim 'https://raw.githubusercontent.com/Yutsuten/linux-config/main/tools/nvim/plugin/statusline.vim'
curl -Lso ~/.config/nvim/plugin/tabline.vim 'https://raw.githubusercontent.com/Yutsuten/linux-config/main/tools/nvim/plugin/tabline.vim'
```
