#!/bin/sh

# Alpine Linux WSL out of box experience script.
#
# This command runs the first time the user opens an interactive shell.
# It creates a default user account and sets up sudo permissions.
#
# A non-zero exit code indicates to WSL that setup failed.

set -ue

DEFAULT_USER_ID=1000

echo 'Please create a default user account. The username does not need to match your Windows username.'
echo 'For more information visit: https://aka.ms/wslusers'

if getent passwd $DEFAULT_USER_ID > /dev/null ; then
  echo 'User account already exists, skipping creation'
  exit 0
fi

# Prompt from the username
read -r -p 'Enter new UNIX username: ' username

# Create the user
adduser -D -u $DEFAULT_USER_ID -G wheel "$username"

cat > /etc/sudoers.d/wsluser << EOF
# Ensure the WSL initial user can use sudo without a password.
#
# Since the user is in the wheel group, this file can be removed
# if you wish to require a password for sudo. Be sure to set a
# user password before doing so with 'sudo passwd $username'!
$username ALL=(ALL) NOPASSWD: ALL
EOF

MAJOR_VERSION=$(cat /etc/alpine-release)
echo "🌟 Start configuring Custom AlpineLinux $MAJOR_VERSION"
log_file="/root/.install.log"
oobe_path="/tmp/oobe"
echo '🔄 Updating system packages...'
apk add --no-network --allow-untrusted 01-update/*.apk >> "$log_file" 2>&1
echo '📦 Installing base components...'
apk add --no-network --allow-untrusted 02-base/*.apk >> "$log_file" 2>&1
rm -rf /tmp/oobe
echo "✅ Custom AlpineLinux $MAJOR_VERSION configuration complete!"

echo 'Your user has been created, is included in the wheel group, and can use sudo without a password.'
echo "To set a password for your user, run 'sudo passwd $username'"
echo "Note: Default password has been set to the username. Please change it for security."