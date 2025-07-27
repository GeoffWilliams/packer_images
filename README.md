# (Fun With) Packer and Nexus

[Packer](https://www.packer.io/) is used to build disk images to run VMs. Since I have quite a few VM images to manage and occasionally need to update an image, this is my [executable documentation](https://en.wikipedia.org/wiki/Infrastructure_as_code) for how to do this.

After building, images are uploaded to nexus for safe keeping. The idea is to build a minimal, reusable OS image. VMs are customized individually with ansible once booted.

## Features

### Common
* `root` password locked
* `geoff` created and added to `sudo` group
* swap disabled
* ssh `authororized_keys` uploaded from `http` directory for `geoff`

### Hyperv
* hostname from vm name (`hyperv-hostname.sh`)

### KVM
* console/tty support
* hostname from bios asset tag (`kvm-hostname.sh`)

## Setup
* Create upload passwords for nexus on Windows and Linux, save to `~/.nexus_password.txt` the output of `openssl rand -base64 16 | tr -dc 'A-Za-z0-9_@%&*!?+=-'`
* Create upload accounts in nexus using password above 

## Hyper-v
Setup:
* packer: `choco install -y packer`
* powershell 7.5 (for `-SkipCertificateCheck` support): `choco install -y powershell-core`, check with `$PSVersionTable.PSVersion`

### Packer build

```powershell
# Debian 12(bookworm)/trixie
packer build .\hyperv_debian_12.9.pkr.hcl
packer build .\hyperv_debian_trixie.pkr.hcl

# Alma 8/9 (RHEL)
packer build .\hyperv_alma_8.10.pkr.hcl
packer build .\hyperv_alma_9.5.pkr.hcl
```

### Nexus upload

```powershell
# allow powershell to run scripts
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
Unblock-File .\scripts\upload.ps1

# EG
.\scripts\upload.ps1 -Artifact hyperv_debian_12.9 -Release 0
.\scripts\upload.ps1 -Artifact hyperv_debian_trixie -Release 0
.\scripts\upload.ps1 -Artifact hyperv_alma_8.10 -Release 0
.\scripts\upload.ps1 -Artifact hyperv_alma_9.5 -Release 0
```

## KVM

Note: UEFI mode

### Packer build

```shell
PACKER_LOG=1 packer build kvm_uefi_debian_12.9.pkr.hcl
PACKER_LOG=1 packer build kvm_uefi_debian_trixie.pkr.hcl
PACKER_LOG=1 packer build kvm_uefi_alma_9.5.pkr.hcl
PACKER_LOG=1 packer build kvm_arm64_debian_12.11.pkr.hcl
```

### Nexus upload
```shell
./scripts/upload.sh kvm_uefi_debian_12.9 0
./scripts/upload.sh kvm_uefi_debian_trixie 0
./scripts/upload.sh kvm_uefi_alma_9.5 0
```

## Troubleshooting

### Test image in qemu - AMD64
* Work on a copy to preserve the original file
* `--cpu max` required for RHEL 9
```shell
qemu-system-x86_64 -bios  /usr/share/OVMF/OVMF_CODE.fd -chardev stdio,id=char0,logfile=serial.log,signal=off -serial chardev:char0 -m 2048 --cpu max temp_image
```

### Test image in qemu - ARM64
* Work on a copy `test.img` to preserve the original file
```shell
qemu-system-aarch64 \
    -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd \
    -m 2048 \
    --cpu host \
    -machine virt \
    -serial mon:stdio \
    -display none \
    -enable-kvm \
    test.img
```
* Exit serial terminal with `ctrl+a` then `c`, then exit qemu console with `quit`


### Create a VM with virt-install

I don't use this any more as using ansible. Just for example:

```shell
virt-install \
    --disk path=/data/vms/xxx.qcow2,device=disk,bus=virtio \
    --os-variant debiantesting \
    --name status \
    --ram 2048 \
    --vcpus 2 \
    --network bridge=br0 \
    --import \
    --virt-type kvm \
    --graphics vnc,password=foobar \
    --console pty,target_type=serial
```

## Gotchas
* Both hyperv and KVM images need to be built on a **local machine**
* If uploading qcow2 images to nexus, they must be compressed or downloads will be slow (script does this automatically)

## Further Reading

* [All debian installer d-i options](https://preseed.debian.net/debian-preseed/bookworm/amd64-main-full.txt)
* [ens3 becomes enp1s0](https://discuss.hashicorp.com/t/using-qemu-builder-gives-network-ens3-after-importing-in-virt-manager-it-becomes-enp1s0/36197/3) (this is all the extra PCI-e codes in KVM build)

