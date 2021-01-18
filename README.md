# dev-config

Configure my development environment.
This configures some tools like Git, Neovim and Zsh.

## Usage

To clone it locally,
I recommend using SSH with `--recurse-submodules`:

```shell
git clone --recurse-submodules git@github.com:Yutsuten/dev-config.git ~/.dev_config
```

To update the submodules:

```shell
git submodule update --init
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
