if test (tty) = '/dev/tty1'
    gsettings set org.gnome.desktop.interface gtk-theme 'Arc'
    gsettings set org.gnome.desktop.interface icon-theme 'Arc'
    gsettings set org.gnome.desktop.interface font-name 'Noto Sans 12'
    gsettings set org.gnome.desktop.interface cursor-theme 'Vimix-cursors'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    exec sway
end
