#!/bin/sh
if ! getent group vanilla-first-setup >/dev/null 2>&1; then
    groupadd vanilla-first-setup
fi

if ! id -u vanilla >/dev/null 2>&1; then
    useradd -m -u 1000 -s /bin/bash -G vanilla-first-setup vanilla
fi
