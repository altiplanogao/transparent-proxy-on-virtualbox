#!/usr/bin/env bash

ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa

cat ./host_id_rsa.pub  >> ~/.ssh/authorized_keys
