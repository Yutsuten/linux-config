#!/usr/bin/bash

set -e
set -u

cat > ~/.config/pipewire/pipewire-pulse.conf.d/90-init.conf << PIPEWIRE_INIT
context.exec = [
    { path = "/usr/bin/bash" args = "$(readlink -e window_manager/pipewire/pipewire-init.sh)" }
]
PIPEWIRE_INIT
