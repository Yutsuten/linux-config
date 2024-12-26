set tctl_dir (paste (ls -1 /sys/class/hwmon/hwmon*/*_input | psub) (cat /sys/class/hwmon/hwmon*/*_label | psub) | sed -nE 's/^([^\t]+)\tTctl$/\1/p')

if test -z "$tctl_dir"
    echo 'Tctl sensor directory not found.'
    return 0
end

set tctl_path (path dirname (path dirname (path resolve $tctl_dir)))
set tctl_basename (path basename $tctl_dir)

sed -e "s#{{ hwmon-path-abs }}#$tctl_path#" \
    -e "s#{{ input-filename }}#$tctl_basename#" \
    desktop/waybar/config.jsonc >~/.config/waybar/config.jsonc
