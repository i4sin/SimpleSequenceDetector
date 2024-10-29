#!/bin/bash
set -eu

main() {
    set_parameter_in_sshd_config "RSAAuthentication" "yes"
    set_parameter_in_sshd_config "PubkeyAuthentication" "yes"
    set_parameter_in_sshd_config "ChallengeResponseAuthentication" "no"
    set_parameter_in_sshd_config "PasswordAuthentication" "no"
    set_parameter_in_sshd_config "UsePAM" "no" 
}

set_parameter_in_sshd_config() {
    sed -i "/^$1/d" /etc/ssh/sshd_config
    bash -c "echo \"$1 $2\" >> /etc/ssh/sshd_config"
}

main
