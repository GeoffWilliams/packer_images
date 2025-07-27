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
  default = "kvm_arm64_debian_12.11"
}

source "qemu" "debian" {
  vnc_bind_address = "0.0.0.0"
  vnc_port_min = "5901"
  vnc_port_max = "5901"
  qemu_binary = "qemu-system-aarch64"
  headless = true
  qemuargs = [
    ["-serial", "file:serial.log"],
    ["-cpu", "host"],
    ["-enable-kvm"],
    
    # https://github.com/hashicorp/packer/issues/10830
    ["-boot", "strict=off"],

    # bios from `sudo apt install qemu-efi-aarch64`
    ["-bios", "/usr/share/AAVMF/AAVMF_CODE.fd"],

    ["-device", "virtio-gpu-pci"],  # Add GPU device
    ["-device", "qemu-xhci"],
    ["-device", "usb-kbd"],


    # for ethernet device numbering
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
  iso_url           = "/home/geoff/Downloads/debian-12.11.0-arm64-netinst.iso"
  iso_checksum      = "sha512:892cf1185a214d16ff62a18c6b89cdcd58719647c99916f6214bfca6f9915275d727b666c0b8fbf022c425ef18647e9759974abf7fc440431c39b50c296a98d3"
  output_directory  = "/home/geoff/packer/builds/${var.vm_name}"
  shutdown_timeout = "1h"
  disk_size         = "100G"
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = "http"
  vm_name           = "${var.vm_name}"
  #net_device        = "virtio-net-pci"
  disk_interface    = "virtio"
  boot_wait         = "5s"
  machine_type      = "virt-7.2"

  # uefi boot
  # https://pkg.go.dev/github.com/hashicorp/packer-plugin-sdk/bootcommand
  boot_command            = [
    # edit
    "<wait>e<wait>",
    "<down><down><down>",
    "<leftCtrlOn>k<leftCtrlOff><wait>",
 
    # "theirs (removed priority=low)"
    " linux /install.a64/vmlinuz ",
    
    # "mine"
    " auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/./kvm/kvm_debian_12_preseed.cfg",
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
  " ---  console=tty0 console=ttyS0",

    "<f10>"
  ]
}

build {
  sources = ["source.qemu.debian"]
}
