packer {
  required_plugins {
    hyperv = {
      source  = "github.com/hashicorp/hyperv"
      version = "~> 1"
    }
  }
}

variable "vm_name" {
  type    = string
  default = "hyperv_debian_trixie"
}

source "hyperv-iso" "debian" {
  # https://github.com/chef/bento/blob/main/os_pkrvars/debian/debian-12-x86_64.pkrvars.hcl
  # https://github.com/chef/bento/blob/main/os_pkrvars/debian/debian-12-aarch64.pkrvars.hcl
  #boot_command            = ["<wait><down>e<wait><down><down><down><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><wait>install <wait> preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>debian-installer=en_US.UTF-8 <wait>auto <wait>locale=en_US.UTF-8 <wait>kbd-chooser/method=us <wait>keyboard-configuration/xkb-keymap=us <wait>fb=false <wait>debconf/frontend=noninteractive <wait>console-setup/ask_detect=false <wait>console-keymaps-at/keymap=us <wait>netcfg/get_hostname=localhost <wait>grub-installer/bootdev=/dev/sda <wait><f10><wait>"]
    boot_wait             = "2s"
  # https://github.com/hashicorp/packer/issues/7315

  # secure boot!!!
  boot_command = [
    "<leftShiftOn><down><leftShiftOff>e<wait><wait><wait>",
    "<leftShiftOn><down><leftShiftOff><leftShiftOn><down><leftShiftOff><leftShiftOn><down><leftShiftOff>",
    "<leftCtrlOn>k<leftCtrlOff><wait>",
 
    # "theirs"
    " linux /install.amd/vmlinuz ",
    
    # "mine"
    # extra "." anchors relative path: https://www.debian.org/releases/trixie/amd64/apbs02.en.html
    " auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/./hyperv/hyperv_debian_13_preseed.cfg",
    " debian-installer=en_US.UTF-8",
    " locale=en_US.UTF-8",
    " kbd-chooser/method=us",
    " keyboard-configuration/xkb-keymap=us",
    " netcfg/get_hostname=localhost",
    " netcfg/get_domain=localdomain",
    " debconf/frontend=noninteractive",
    " console-setup/ask_detect=false",
    " console-keymaps-at/keymap=us",
    " grub-installer/bootdev=/dev/sda",
    "<f10>"
  ]
  communicator          = "none"
  vm_name               = "${var.vm_name}"
  cpus                  = "2"
  memory                = "16384"
  disk_size             = "80000"
  iso_url              = "file://C:/Users/geoff/Downloads/debian-trixie-DI-alpha1-amd64-netinst.iso"
  iso_checksum          = "sha512:ca36d84599cbdb7dfcb8b46f4cf73e8f5c695c7c94f00427c12b86a44136e19b7fa9465424ed07af3229bcb8139d77399709aa4a40dc19c285c789b76c36b373"
  headless              = false
  http_directory        = "http"
  enable_dynamic_memory = false
  enable_secure_boot    = true
  guest_additions_mode  = "disable"
  switch_name           = "bridge"
  generation            = "2"
  secure_boot_template  = "MicrosoftUEFICertificateAuthority"
  configuration_version = "11.0"
  output_directory      = "builds/${var.vm_name}"
  disable_shutdown = true
  shutdown_timeout = "1h"
}

build {
  sources = ["source.hyperv-iso.debian"]
}