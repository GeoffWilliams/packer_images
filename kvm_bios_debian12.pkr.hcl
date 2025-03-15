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
  default = ""
}

source "qemu" "debian12" {
  # headless = true
    communicator          = "none"
  cpus                  = "2"
  memory                = "2048"
  iso_url           = "/home/geoff/Downloads/debian-12.9.0-amd64-netinst.iso"
  iso_checksum      = "sha512:9ebe405c3404a005ce926e483bc6c6841b405c4d85e0c8a7b1707a7fe4957c617ae44bd807a57ec3e5c2d3e99f2101dfb26ef36b3720896906bdc3aaeec4cd80"
  output_directory  = "/home/geoff/packer/builds/${var.vm_name}"
  shutdown_timeout = "1h"
  disk_size         = "100G"
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = "http"
  vm_name           = "debian12"
  net_device        = "virtio-net"
  disk_interface    = "virtio"
  boot_wait         = "2s"

  # oldschool boot
  boot_command      = [
    "<down>",
    "<tab>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    " auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kvm_debian12_preseed.cfg",
    " <wait>debian-installer=en_US.UTF-8",
    " <wait>locale=en_US.UTF-8",
    " <wait>kbd-chooser/method=us",
    " <wait>keyboard-configuration/xkb-keymap=us",
    " <wait>netcfg/get_hostname=localhost",
    " <wait>netcfg/get_domain=localdomain",
    " <wait>debconf/frontend=noninteractive",
    " <wait>console-setup/ask_detect=false",
    " <wait>console-keymaps-at/keymap=us",
    " <wait>grub-installer/bootdev=/dev/vda",
    " <wait> --- console=ttyS0,9600n8",
    " <wait><enter>"
  ]
}

build {
  sources = ["source.qemu.debian12"]
}
