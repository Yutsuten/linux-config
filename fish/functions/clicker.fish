function clicker --description 'Autoclicker for Sway'
    sleep $argv[1] || return
    while true
        swaymsg seat seat0 cursor press button1
        sleep 0.01s
        swaymsg seat seat0 cursor release button1
        sleep $argv[1]
    end
end
