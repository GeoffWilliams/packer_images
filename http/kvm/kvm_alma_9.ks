text
eula --agreed
url --url https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/


# Turn off after installation
poweroff

# Do not start the Inital Setup app
firstboot --disable

# System language, keyboard and timezone
lang en_US.UTF-8
keyboard us
timezone Australia/Sydney

# Set the first NIC to acquire IPv4 address via DHCP
network --device eth0 --bootproto=dhcp --activate
# Disable firewall
firewall --disabled
# Enable SELinux with default enforcing policy
selinux --enforcing

# Do not set up XX Window System
skipx

# Initial disk setup
ignoredisk --only-use=vda
clearpart --all --initlabel --drives=vda

part /boot --fstype=ext4 --ondisk=vda --size=512 --label=boot
part /boot/efi --fstype=efi --ondisk=vda --size=1024 --label=EFI
part pv.01 --fstype=lvmpv --size 1 --grow --ondisk=vda --label=rhel9

volgroup rhel9 pv.01

logvol / --fstype ext4 --vgname=rhel9 --grow --percent=80 --name=root 
logvol /data --fstype ext4 --vgname=rhel9 --grow --percent=20 --name=data

# lock root password
rootpw --lock

# Add a user named geoff to new group sudo
group --name=sudo
user --groups=sudo --name=geoff --password=geoff --plaintext --gecos="geoff" --homedir=/home/geoff

%post --erroronfail

PACKER_SERVER=$(cat /proc/cmdline | awk 'BEGIN {RS=" "; FS="="} /packer_server/ {printf $2}')
echo "packer server: $PACKER_SERVER"
set -x


# Passwordless sudo for everyone in group sudo"
echo "%sudo ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/sudo
chmod 440 /etc/sudoers.d/sudo

# ssh key
mkdir /home/geoff/.ssh/
chmod 0700 /home/geoff/.ssh
chown geoff:geoff /home/geoff/.ssh
curl "${PACKER_SERVER}/authorized_keys" -o /home/geoff/.ssh/authorized_keys
chmod 0600 /home/geoff/.ssh/authorized_keys
chown geoff:geoff /home/geoff/.ssh/authorized_keys

# get hostname from KVM metadata every reboot
curl "${PACKER_SERVER}/kvm/kvm-hostname.sh" -o /usr/local/bin/kvm-hostname.sh
chmod +x /usr/local/bin/kvm-hostname.sh
curl "${PACKER_SERVER}/kvm/kvm-hostname.service" -o /etc/systemd/system/kvm-hostname.service
chmod +x /etc/systemd/system/kvm-hostname.service
systemctl enable kvm-hostname

%end

%packages
@Core
bash-completion
sudo
openssh
grub2-efi-x64
shim-x64
grub2-efi-x64-modules
efibootmgr
dosfstools
lvm2
mdadm
device-mapper-multipath
iscsi-initiator-utils
-plymouth
# Remove ALSA firmware
-a*-firmware
# Remove Intel wireless firmware
-i*-firmware
vim
%end
