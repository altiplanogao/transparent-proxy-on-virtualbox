#!/usr/bin/env bash

mv /home/vagrant/resources /resources

echo "==================================="
env
echo "==================================="

# # update root password
# echo -e "password\npassword" | passwd

chmod +x /resources/bootstrap.sh

/resources/bootstrap.sh
