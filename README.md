# linux-config

Configure my linux environment.
This configures some tools like Git, Neovim and Zsh.

## Usage

To clone it locally,
I recommend using SSH with `--recurse-submodules`:

```shell
git clone --recurse-submodules git@github.com:Yutsuten/linux-config.git ~/.linux_config
```

To update the submodules:

```shell
git submodule update --init
```

Then apply the configuration with the commands bellow:

```shell
make              # User configuration
sudo make system  # System-wide configuration
```

## Dependencies

Install the dependencies for this configuration into your system.

### Arch Linux

```shell
sudo pacman -S flake8 python-pylint python-language-server eslint yarn
yarn global add htmlhint jshint
```

### Ubuntu

```shell
sudo apt install flake8 pylint yarn
yarn global add eslint htmlhint jshint
```

### Homebrew

```shell
brew install python flake8 pylint
pip3 install --user python-language-server
```
