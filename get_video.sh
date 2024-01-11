#!/bin/bash
if [ -z "$SSH_AUTH_SOCK" ]
then
  export SSH_AUTH_SOCK=/run/user/1000/keyring/ssh
fi
rsync --progress --remove-source-files -u pi@<remote_ip>:~/PorchFootage/*.mkv .
