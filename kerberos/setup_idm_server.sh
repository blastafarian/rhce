#!/bin/bash

# Set up Red Hat Identity Management (IdM)
# ===========================================================================

IP_ADDRESS="192.168.56.5/24"
source ../00_general/setup.sh

# Install IdM packages
sudo yum install ipa-server bind bind-dyndb-ldap

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

# Backup the CA cert stored in /root/cacert.p12
# This file is required to create replicas
sudo mkdir /var/tmp/bak/root
sudo cp -p /root/cacert.p12 /var/tmp/bak/root
