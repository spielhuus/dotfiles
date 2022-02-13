#/bin/bash

MODE=$1
TARGET=$2
#list=('install' 'uninstall')

#echo "start $MODE"
#[[ $list =~ (^|[[:space:]])"$MODE"($|[[:space:]]) ]] || echo "mode is not set [install|uninstall]" exit 
[[ -z $TARGET ]] && TARGET=$HOME/.config

echo "start $MODE"
case $MODE in

  install)
    echo "create symlinks in $TARGET"
    for f in *; do
        if [ -d "$f" ]; then
            if [ -e $TARGET/$f ]; then
            echo "file $TARGET/$f exists, skip it"
        else
            ln -s `pwd`/$f $TARGET/$f
        fi
    fi
    done
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
    ;;

  *)
    echo "unkown command $MODE"
    exit -1
    ;;
esac
