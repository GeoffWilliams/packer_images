#!/bin/bash
# https://stackoverflow.com/a/64765093/3441106

# doesn't always work first time, maybe sleep would help?
sleep 10

fname=/var/lib/hyperv/.kvp_pool_3
if [ ! -f $fname ] ; then
	echo "$fname does not exist - hyperv integration for linux loaded?"
	exit 1
fi
echo "Reading $fname"
nb=$(wc -c < $fname)
nkv=$(( nb / (512+2048) ))
current_hostname=$(cat /etc/hostname)
for n in $(seq 0 $(( $nkv - 1 )) ); do
        offset=$(( $n * (512 + 2048) ))
        k=$(dd if=$fname count=512 bs=1 skip=$offset status=none | sed 's/\x0.*//g')
        v=$(dd if=$fname count=2048 bs=1 skip=$(( $offset + 512 )) status=none | sed 's/\x0.*//g')
        echo "$k = $v"
	if [ "$k" == "VirtualMachineName" ] && [ "$current_hostname" != "$v" ]; then
		echo "**** update hostname $current_hostname -> $v***"
        hostnamectl set-hostname $v
		echo "reboot!"
        reboot
	fi
done