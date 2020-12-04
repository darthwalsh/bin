#!/usr/bin/env bash
termux-chroot 
sshd 
echo "$(whoami)@$(ifconfig arc0 | awk '/inet /{print $2}'):8022"

