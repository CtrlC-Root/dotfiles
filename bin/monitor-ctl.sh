#!/bin/bash

MONITOR=$1; shift;
COMMAND=$1; shift;

function switch_input {
    MONITOR=$1
    INPUT_NAME=$2

    INPUT_VALUE=$(ddcutil vcpinfo -v -d "${MONITOR}" 0x60 \
        | grep "${INPUT_NAME}" \
        | cut -d':' -f1 \
        | tr -d ' ')

    ddcutil --noverify setvcp -d "${MONITOR}" 0x60 "${INPUT_VALUE}"
}

function brightness {
    MONITOR=$1
    VALUE=$2 # 0-100, `ddcutil getgcp -v` shows maximum value

    ddcutil --noverify setvcp -d "${MONITOR}" 0x10 "${VALUE}"
}

case "${COMMAND}" in
    "input-dp")
        switch_input $MONITOR "DisplayPort-1"
        ;;
    "input-hdmi1")
        switch_input $MONITOR "HDMI-1"
        ;;
    "input-hdmi2")
        switch_input $MONITOR "HDMI-2"
        ;;
    "brightness")
        brightness $MONITOR $1
        ;;
esac
