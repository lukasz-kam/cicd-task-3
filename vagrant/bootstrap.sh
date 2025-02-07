#!/bin/bash

echo "Starting bootstrap.sh..."

sudo apt-get update
sudo apt install -y --no-install-recommends openjdk-17-jdk-headless

cat /mnt/my_files/.pub_key >> /home/vagrant/.ssh/authorized_keys

echo "PubkeyAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
echo "AuthorizedKeysFile .ssh/authorized_keys" | sudo tee -a /etc/ssh/sshd_config

echo "Configuration finished!"
