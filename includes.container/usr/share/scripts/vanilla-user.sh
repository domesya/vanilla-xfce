#!/bin/sh
# Only run system user/group provisioning if running as root
if [ "$(id -u)" -eq 0 ]; then
    getent group vanilla-first-setup || groupadd -g 990 vanilla-first-setup
    id -u vanilla || useradd -m -u 1000 -s /bin/bash -G vanilla-first-setup vanilla
else
    echo "Notice: Skipping system user/group creation (not running as root)." >&2
fi
