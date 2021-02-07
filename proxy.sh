#!/bin/bash
#Stephanie's Proxy setup - inside the VM
#Root Required
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

#Setup Squid Proxy
yum install nano squid httpd-tools -y
htpasswd -bc /etc/squid/passwd bacon piggy

cat > /etc/squid/squid.conf <<EOL
auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm proxy
acl authenticated proxy_auth REQUIRED
acl smtp port 25
http_access allow authenticated
http_port 0.0.0.0:3128
http_access deny smtp
http_access deny all
forwarded_for delete
EOL

touch /etc/squid/blacklist.acl
systemctl restart squid.service && systemctl enable squid.service
iptables -I INPUT -p tcp --dport 3128 -j ACCEPT
iptables-save
