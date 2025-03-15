packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}


variable "vm_name" {
  type    = string
  default = "kvm_uefi_debian_trixie"
}

source "qemu" "debian" {
  # when building on server over ssh
  # headless = true
  qemuargs = [
    ["-bios", "/usr/share/OVMF/OVMF_CODE.fd"],
    ["-chardev", "stdio,id=char0,logfile=serial.log,signal=off"],
    ["-serial", "chardev:char0"],

    ["-device", <<-EOT
    {"driver":"pcie-root-port","port":8,"chassis":1,"id":"pci.1","bus":"pcie.0","multifunction":true,"addr":"0x7"}
    EOT
    ],
    ["-netdev", <<-EOT
    {"type":"user","id":"hostnet0"} 
    EOT
    ],
    ["-device", <<-EOT
    {"driver":"virtio-net-pci","netdev":"hostnet0","id":"net0","mac":"de:ad:be:ef:ca:fe","bus":"pci.1","addr":"0x0"}
    EOT
    ]

  ]
  communicator          = "none"
  cpus                  = "2"
  memory                = "2048"
  iso_url           = "/home/geoff/Downloads/debian-trixie-DI-alpha1-amd64-netinst.iso"
  iso_checksum      = "sha512:ca36d84599cbdb7dfcb8b46f4cf73e8f5c695c7c94f00427c12b86a44136e19b7fa9465424ed07af3229bcb8139d77399709aa4a40dc19c285c789b76c36b373"
  output_directory  = "/home/geoff/packer/builds/${var.vm_name}"
  shutdown_timeout = "1h"
  disk_size         = "100G"
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = "http"
  vm_name           = "${var.vm_name}"
  #net_device        = "virtio-net-pci"
  disk_interface    = "virtio"
  boot_wait         = "2s"
  machine_type      = "pc-q35-7.2"

  # uefi boot
  # https://pkg.go.dev/github.com/hashicorp/packer-plugin-sdk/bootcommand
  boot_command            = [
    "<down>e<wait><wait><wait>",
    "<down><down><down>",
    "<leftCtrlOn>k<leftCtrlOff><wait>",
 
    # "theirs"
    " linux /install.amd/vmlinuz ",
    
    # "mine"
    " auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/./kvm/kvm_debian_13_preseed.cfg",
    " debian-installer=en_US.UTF-8",
    " locale=en_US.UTF-8",
    " kbd-chooser/method=us",
    " keyboard-configuration/xkb-keymap=us",
    " netcfg/get_hostname=localhost",
    " netcfg/get_domain=localdomain",
    " debconf/frontend=noninteractive",
    " console-setup/ask_detect=false",
    " console-keymaps-at/keymap=us",
    " grub-installer/bootdev=/dev/vda",
    " --- console=tty0 console=ttyS0,9600",
    "<f10>"
  ]
}

build {
  sources = ["source.qemu.debian"]
}
