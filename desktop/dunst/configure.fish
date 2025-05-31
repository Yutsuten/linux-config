set update_systray_script (path resolve 'desktop/dunst/update_systray')

sed -e "s#{{ update-systray-script }}#$update_systray_script#" \
    desktop/dunst/dunstrc.conf >~/.config/dunst/dunstrc
