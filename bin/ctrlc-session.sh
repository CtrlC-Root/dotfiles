#!/bin/bash

# background
if which feh &> /dev/null ; then
    feh --bg-scale ~/backgrounds/*
fi

# compton
if which compton &> /dev/null ; then
    # stop existing instances
    killall -u $USER -e compton
    while pgrep -u $USER compton > /dev/null; do sleep "0.1s"; done

    # start compton
    compton -b
fi

# polybar
if which polybar &> /dev/null ; then
    # stop existing instances
    killall -u $USER -e polybar
    while pgrep -u $USER polybar > /dev/null; do sleep "0.1s"; done

    # start new instances
    polybar desktop -q &
fi
