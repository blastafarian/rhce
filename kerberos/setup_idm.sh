#!/bin/bash

# Set up Red Hat Identity Management (IdM)

# Don't use a GUI - boot to multi-user instead, to save resources and prevent
# PackageKit from running
systemctl set-default multi-user.target

# Install IdM packages and ensure all packages are up-to-date
sudo yum install ipa-server bind bind-dyndb-ldap
sudo yum update

# Disable graphical boot
sudo mkdir -p /var/tmp/bak/boot/grub2
sudo cp -p /boot/grub2/grub.cfg /var/tmp/bak/boot/grub2
sudo vi /etc/default/grub
# (Find the variable GRUB_CMDLINE_LINUX, and remove 'rhgb quiet' from it)
sudo grub2-mkconfig -o /tmp/grub.cfg
sudo cp /tmp/grub.cfg /boot/grub2

# Configure a host-only network connection
systemctl poweroff
# (In VirtualBox, create a new host-only network adapter)
# (Start the server again)
sudo nmcli con edit 'Wired connection 1'
> set connection.id hostonly
> set ipv4.method manual  
> set ipv4.addresses 192.168.56.5/24
> set ipv4.dns 192.168.56.5
> set ipv4.dns-search blastafarian.com
> set ipv4.never-default yes
> verify
> save persistent
> save temporary
> quit
nmcli dev disconnect enp0s8
nmcli con up hostonly
nmcli con show hostonly
# (Verify hostonly connection details)

# Re-connect via SSH rather than through console
systemctl poweroff
# (In VirtualBox, hold Shift while double-clicking kdc.blastafarian.com to
# start kdc.blastafarian.com in a headless state)
ssh-copy-id 192.168.56.5
ssh 192.168.56.5

# Allow IdM services through firewall
for myservice in http https kerberos ldap ldaps dns ntp; do
  printf "Allowing ${myservice} service through public zone of firewall... "
  sudo firewall-cmd --zone=public --add-service=${myservice} || break
done

# (Poweroff the server and, in VirtualBox, clone the server, so that even if
# IPA installation corrupts the server, I can start retry IPA installation on
# the clone)

# Configure IdM
sudo ipa-server-install

# (In /etc/hosts, remove binding of kdc.blastafarian.com to 10.0.2.15)

# Remove A record that maps kdc.blastafarian.com to 10.0.2.15
ipa dnsrecord-del blastafarian.com kdc
# Remove corresponding PTR record
ipa dnsrecord-del 2.0.10.in-addr.arpa. 15

# Verify DNS records
ipa dnsrecord-find blastafarian.com
ipa dnsrecord-find 2.0.10.in-addr.arpa.
ipa dnsrecord-find 56.168.192.in-addr.arpa.
dig kdc.blastafarian.com
dig +search kdc
dig 5.56.168.192.in-addr.arpa
dig 15.2.0.10.in-addr.arpa

# Restart sshd to obtain Kerberos credentials
sudo systemctl restart sshd
kinit admin

# Verify IPA access:
ipa user-find admin
