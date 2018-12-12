# bash-config
The configurations I use to personalize my bash.

## How to use
Load the script in the top of the `~/.bashrc` or `~/.bash_profile`:
```shell
source ~/bash-config/prompt.sh
```

Append the `USER_PROMPT` variable to the `PS1`:
```shell
# Example in debian
PS1="${debian_chroot:+($debian_chroot)}${USER_PROMPT}"
```

## Result
```shell
[20:54] user@hostname:~/bash-config (master)
$
```
