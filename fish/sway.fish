set TTY1 (tty)
if [ "$TTY1" = "/dev/tty1" ]
  # GTK theme
  gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark'
  gsettings set org.gnome.desktop.interface icon-theme 'Arc'
  gsettings set org.gnome.desktop.interface font-name 'Noto Sans 12'
  gsettings set org.gnome.desktop.interface cursor-theme 'Vimix-cursors'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

  # Start sway
  exec sway
end
