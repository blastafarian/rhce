#!/bin/bash

# Set up Red Hat Identity Management (IdM)

# Uninstall ntpd and chrony as they interfere with IdM
if yum list installed | egrep '^ntp\.' 2>&1 > /dev/null; then
  sudo yum -y remove ntp
fi
if yum list installed | egrep '^chrony\.' 2>&1 > /dev/null; then
  sudo yum -y remove chrony
fi

# Allow IdM services through firewall
for myservice in http https kerberos ldap ldaps dns ntp; do
  printf "Allowing ${myservice} service through public zone of firewall... "
  sudo firewall-cmd --zone=public --add-service=${myservice} || break
done

# Install IdM packages
sudo yum install -y ipa-server bind-dyndb-ldap

# Configure IdM
sudo ipa-server-install
