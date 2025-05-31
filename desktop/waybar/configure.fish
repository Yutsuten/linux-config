set tctl_dir (paste (printf '%s\n' /sys/class/hwmon/hwmon*/*_input | psub) (cat /sys/class/hwmon/hwmon*/*_label | psub) | sed -nE 's/^([^\t]+)\tTctl$/\1/p')

if test -z "$tctl_dir"
    echo 'Tctl sensor directory not found.'
    return 0
end

set tctl_path (path dirname (path dirname (path resolve $tctl_dir)))
set tctl_basename (path basename $tctl_dir)
set notification_script (path resolve 'desktop/waybar/notification')

sed -e "s#{{ hwmon-path-abs }}#$tctl_path#" \
    -e "s#{{ input-filename }}#$tctl_basename#" \
    -e "s#{{ notification-script }}#$notification_script#" \
    desktop/waybar/config.jsonc >~/.config/waybar/config.jsonc
