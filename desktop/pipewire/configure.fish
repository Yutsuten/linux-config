mkdir --parents ~/.config/pipewire/pipewire-pulse.conf.d

set init_abs_path (path resolve desktop/pipewire/init.sh)

ln -f desktop/pipewire/10-remap-sink.conf ~/.config/pipewire/pipewire-pulse.conf.d/10-remap-sink.conf
sed -e "s#{{ init-abs-path }}#$init_abs_path#" desktop/pipewire/90-init.conf >~/.config/pipewire/pipewire-pulse.conf.d/90-init.conf
