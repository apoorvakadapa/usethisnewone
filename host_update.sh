#!/bin/bash

echo "********Starting Update of /etc/hosts file****************"
echo "Backing up /etc/hosts file"
sudo cp /etc/hosts /etc/hosts.orginal
LOCAL_HOSTNAME=$(hostname)
LOCAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4 -s)


sudo rm /tmp/hosts_updated
sudo cat << EOF >> /tmp/hosts_updated
$LOCAL_IP  $LOCAL_HOSTNAME 127.0.0.1
EOF

echo "Replacing /etc/hosts with update hostname"
sudo cp /tmp/hosts_updated /etc/hosts
echo "Updated /etc/hosts file"
echo ""
echo ""
echo ""
