#!/bin/zsh

x=$(nmcli -a | grep 'Wired connection' | awk 'NR==1{print $1}')
y=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -c 5-)

if [ -z "$x" ] && [ -z "$y" ]; then
    notify-send "Not Connected"
    exit 1
elif [ -z "$x" ]; then 
    notify-send "Connected to $y"
    exit 1
elif [ -z "$y" ]; then
    notify-send "Connected to $x"
    exit 1
fi