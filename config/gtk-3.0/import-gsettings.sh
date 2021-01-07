#!/bin/sh

# usage: import-gsettings.sh
config="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/settings.ini"
if [ ! -f "$config" ]; then exit 1; fi

gnome_schema="org.gnome.desktop.interface"

function get_setting() {
  grep "$1" "$config" | cut -d '=' -f 2
}

function apply_setting() {
  value="$(get_setting "$1")"
  if ! [ -z "$value" ]; then
    echo gsettings set "$gnome_schema" "$1" "$value"
  fi
}

apply_setting gtk-theme
apply_setting icon-theme
apply_setting cursor-theme
apply_setting font-name
