# linux-config

Configure my linux environment.
This configures some tools like Git, Neovim and Fish.

It uses Sway as Window Manager.

## Usage

Clone the repository:

```shell
git clone git@github.com:Yutsuten/linux-config.git ~/.config/linux
git submodule update --init
```

Apply the configuration:

```shell
make
sudo make system
```

This only places the configuration files.
The installation of the applications should be done separately.
