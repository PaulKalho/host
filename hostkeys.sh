#!/bin/bash

set -e

EXTRA_FILES_DIR="tmp/extra-files"
SSH_DIR="${EXTRA_FILES_DIR}/etc/ssh"

if [ ! -d "$SSH_DIR" ]; then
    mkdir -p "$SSH_DIR"
fi

chmod 755 $SSH_DIR

KEY_FILE="$SSH_DIR/ssh_host_ed25519_key"
if [ ! -f "$KEY_FILE" ]; then
    ssh-keygen -t ed25519 -f "$KEY_FILE" -N "" -C "" -q
else
    echo "$KEY_FILE already exists, skipping generation."
fi

AGE_KEY=$(cat "${KEY_FILE}.pub" | ssh-to-age)
echo $AGE_KEY
