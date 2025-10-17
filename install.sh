#!/bin/bash

MODE=$1
TARGET=$2

[[ -z $TARGET ]] && TARGET=$HOME/.config

case $MODE in

install)
	echo "create symlinks in $TARGET"
	for f in *; do
		if [ -d "$f" ]; then
			if [ -e $TARGET/$f ]; then
				echo "file $TARGET/$f exists, skip it"
			else
				ln -s $(pwd)/$f $TARGET/$f
			fi
		fi
	done
  cp .gtkrc-2.0 ~/.gtkrc-2.0
  gsettings set org.gnome.desktop.interface gtk-theme Breeze-Dark
  gsettings set org.gnome.desktop.wm.preferences theme Breeze-Dark
	;;

uninstall)
	echo "remove symlinks in $TARGET"
	for f in *; do
		if [ -d "$f" ]; then
			if [ -e $TARGET/$f ]; then
				rm $TARGET/$f
			fi
		fi
	done
  rm ~/.gtkrc-2.0
	;;

*)
	echo "unkown command $MODE"
	exit -1
	;;
esac
