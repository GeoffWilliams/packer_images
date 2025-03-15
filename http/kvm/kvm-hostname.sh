#!/bin/bash

# kvm name sent via smbios asset tag qemu arg
KVM_HOSTNAME=$(cat /sys/class/dmi/id/chassis_asset_tag)
CURRENT_HOSTNAME=$(cat /etc/hostname)

if [ -n "$KVM_HOSTNAME" ] && [ "$CURRENT_HOSTNAME" != "$KVM_HOSTNAME" ] ; then
    echo "***** update hostname $CURRENT_HOSTNAME -> $KVM_HOSTNAME *****"
    hostnamectl set-hostname $KVM_HOSTNAME
    echo "reboot!"
    reboot
elif [ -n "$KVM_HOSTNAME" ] && [ "$CURRENT_HOSTNAME" = "$KVM_HOSTNAME" ] ; then
    echo "hostname is up-to-date"
    exit 0
elif [ -z "$KVM_HOSTNAME" ] ; then
    echo "KVM name not found in asset tag. Exit"
    exit 1
else
    echo "coding error"
    exit 1
fi
