#!/usr/bin/env bash

echo -ne "\n#DISABLE PASSWORD LOGIN [START]\nPasswordAuthentication no\n#DISABLE PASSWORD LOGIN [END]\n" >> /etc/ssh/sshd_config

service sshd restart