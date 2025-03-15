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
  default = "kvm_uefi_alma_9.5"
}

source "qemu" "alma" {
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
  iso_url           = "/home/geoff/Downloads/AlmaLinux-9.5-x86_64-minimal.iso"
  iso_checksum      = "sha256:eef492206912252f2e24a74d3133b46cb4d240b54ffb3300a94000905b2590d3"
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
  machine_type      = "q35"

  # required to boot RHEL9
  # https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu
  cpu_model = "host"

  # uefi boot
  # https://pkg.go.dev/github.com/hashicorp/packer-plugin-sdk/bootcommand
  boot_command     = [
    "<up>",
    "e<wait2s>",
    "<down>",
    "<down>",
    "<end>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kvm/kvm_alma_9.ks ",
    "packer_server=http://{{ .HTTPIP }}:{{ .HTTPPort }}",
    "<wait2s>",
    "<leftCtrlOn>x<leftCtrlOff>"
  ]
}

build {
  sources = ["source.qemu.alma"]
}
