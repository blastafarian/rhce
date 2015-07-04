#!/bin/bash

# General setup for a RHEL system
# ===========================================================================

# Expect the IP address of the hostonly interface to be already defined
if [[ -z "${IP_ADDRESS}" ]];
  echo >&2 "Error: IP address not defined"
  exit 1
fi

# Enable password-less sudo
sudo visudo

# Don't use a GUI - boot to multi-user instead, to save resources and prevent
# PackageKit from running
sudo systemctl set-default multi-user.target

# Disable graphical boot
sudo mkdir -p /var/tmp/bak/boot/grub2
sudo cp -p /boot/grub2/grub.cfg /var/tmp/bak/boot/grub2
sudo vi /etc/default/grub
# (Find the variable GRUB_CMDLINE_LINUX, and remove 'rhgb quiet' from it)
sudo grub2-mkconfig -o /tmp/grub.cfg
sudo cp /tmp/grub.cfg /boot/grub2

# Ensure all packages are up-to-date
sudo yum update

# Create a new adapter and connect it to the host-only network
systemctl poweroff
# (In VirtualBox, create a new host-only network adapter)
# (Start the server again)
sudo nmcli con modify 'Wired connection 1' connection.id hostonly
sudo nmcli con modify hostonly ipv4.addresses "${IP_ADDRESS}"
sudo nmcli con modify hostonly ipv4.method manual  
sudo nmcli con modify hostonly ipv4.dns 192.168.56.5
sudo nmcli con modify hostonly ipv4.dns-search blastafarian.com
sudo nmcli con modify hostonly ipv4.never-default yes
nmcli dev disconnect enp0s8
nmcli con up hostonly
nmcli con show hostonly
# (Verify hostonly connection details)

# Re-connect via SSH rather than through console
systemctl poweroff
# (In my host system, add '192.168.56.3 client.blastafarian.com' to /etc/hosts)
# (In VirtualBox, hold Shift while double-clicking client.blastafarian.com to
# start client.blastafarian.com in a headless state)
# (On host: ssh-copy-id client.blastafarian.com)
# (On host: ssh client.blastafarian.com)

