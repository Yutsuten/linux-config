#!/usr/bin/fish

while true
    swaymsg seat seat0 cursor move -- 1 0
    sleep 0.050s
    swaymsg seat seat0 cursor move -- -1 0
    sleep 0.050s
end
