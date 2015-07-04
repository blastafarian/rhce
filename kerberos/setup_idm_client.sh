#!/bin/bash

# Refers to section 5.4 "Manually Configuring a Linux Client" of
# "RHEL 7 Linux Domain Identity, Authentication and Policy Guide"

IP_ADDRESS="192.168.56.3/24"
source ../00_general/setup.sh

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

# Configure a host-only network connection
systemctl poweroff

# Ensure all packages are up-to-date
sudo yum update

# (In VirtualBox, create a new host-only network adapter)
# (Start the server again)
sudo nmcli con edit 'Wired connection 1'
# > set connection.id hostonly
# > set ipv4.method manual  
# > set ipv4.addresses 192.168.56.3/24
# > set ipv4.dns 192.168.56.5
# > set ipv4.dns-search blastafarian.com
# > set ipv4.never-default yes
# > verify
# > save persistent
# > save temporary
# > quit
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

