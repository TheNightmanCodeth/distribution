#!/bin/bash

. /etc/profile

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")

/usr/share/torzu-sa/yuzu-cmd --fullscreen -g $GAME
