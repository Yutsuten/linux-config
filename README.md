# linux-config

Configure my linux environment.
This configures some tools like Git, Neovim and Zsh.

## Usage

Clone the repository:

```shell
git clone --recurse-submodules git@github.com:Yutsuten/linux-config.git ~/.linux_config
```

Apply the configuration:

```shell
make user_all
sudo make system_all
```

Install the language servers and linters for neovim and its done!
