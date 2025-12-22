#!/usr/bin/bash

# The Fedora WSL out of box experience script.
#
# This command runs the first time the user opens an interactive shell if
# `cloud-init` is not enabled.
#
# A non-zero exit code indicates to WSL that setup failed.

set -ueo pipefail

DEFAULT_USER_ID=1000

if systemctl is-enabled cloud-init.service > /dev/null ; then
  echo 'cloud-init is enabled, skipping user account creation. Waiting for cloud-init to finish.'
  cloud-init status --wait > /dev/null 2>&1
  exit 0
fi

echo 'Please create a default user account. The username does not need to match your Windows username.'
echo 'For more information visit: https://aka.ms/wslusers'

if getent passwd $DEFAULT_USER_ID > /dev/null ; then
  echo 'User account already exists, skipping creation'
  exit 0
fi

# Prompt from the username
read -r -p 'Enter new UNIX username: ' username

# Create the user
/usr/sbin/useradd -m -G wheel --uid $DEFAULT_USER_ID "$username"

cat > /etc/sudoers.d/wsluser << EOF
# Ensure the WSL initial user can use sudo without a password.
#
# Since the user is in the wheel group, this file can be removed
# if you wish to require a password for sudo. Be sure to set a
# user password before doing so with 'sudo passwd $username'!
$username ALL=(ALL) NOPASSWD: ALL
EOF

MAJOR_VERSION=$(rpm -q --qf '%{VERSION}' rocky-release | cut -d '.' -f 1)
echo "🌟 Start configuring Custom RockyLinux $MAJOR_VERSION"
log_file="/root/.install.log"
echo '⚙️ Configuring DNF for faster downloads...'
echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf
chmod 644 /etc/profile.d/bash-color-prompt.sh
echo '🔄 Updating system packages...'
dnf install -y /tmp/oobe/01-update/*.rpm --disablerepo=\* --nogpgcheck >> "$log_file" 2>&1
echo '📦 Installing base components...'
dnf install -y /tmp/oobe/02-base/*.rpm --disablerepo=\* --nogpgcheck >> "$log_file" 2>&1
echo '📡 Installing EPEL repository and base packages...'
dnf install -y /tmp/oobe/03-epel/*.rpm --disablerepo=\* --nogpgcheck >> "$log_file" 2>&1
if [ -d /tmp/oobe/06-docker ]; then
    echo '🐳 Installing Docker...'
    mv /tmp/oobe/06-docker/docker-ce.repo /etc/yum.repos.d/docker-ce.repo
    dnf install -y /tmp/oobe/06-docker/*.rpm --disablerepo=\* --nogpgcheck >> "$log_file" 2>&1
    echo '🛠️ Configuring Docker daemon...'
    mkdir -p /etc/docker
    echo '{}' > /etc/docker/daemon.json
    echo '🚀 Enabling and starting Docker service...'
    systemctl enable --now docker >> "$log_file" 2>&1
    echo "👤 Adding user '$username' to Docker group..."
    usermod -aG docker "$username"
fi
echo '🧹 Cleaning up...'
dnf remove --oldinstallonly -y >> "$log_file" 2>&1
dnf clean all >> "$log_file" 2>&1
rm -rf /tmp/oobe
echo "✅ Custom RockyLinux $MAJOR_VERSION configuration complete!"

echo 'Your user has been created, is included in the wheel group, and can use sudo without a password.'
echo "To set a password for your user, run 'sudo passwd $username'"
