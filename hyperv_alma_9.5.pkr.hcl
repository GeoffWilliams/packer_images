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
  default = "hyperv_alma_9.5"
}

source "hyperv-iso" "alma" {
  boot_command     = [
    "<leftShiftOn><up><leftShiftOff>",
    "e<wait1s>",
    "<leftShiftOn><down><leftShiftOff>",
    "<leftShiftOn><down><leftShiftOff>",
    "<leftShiftOn><end><leftShiftOff> ",
    "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/hyperv/hyperv_alma_9.ks ",
    "packer_server=http://{{ .HTTPIP }}:{{ .HTTPPort }}",
    "<wait2s>",
    "<leftCtrlOn>x<leftCtrlOff>"
  ]
  boot_wait             = "4s"
  communicator          = "none"
  vm_name               = "${var.vm_name}"
  cpus                  = "2"
  memory                = "16384"
  disk_size             = "80000"
  iso_url              = "file://C:/Users/geoff/Downloads/AlmaLinux-9.5-x86_64-minimal.iso"
  iso_checksum          = "sha256:eef492206912252f2e24a74d3133b46cb4d240b54ffb3300a94000905b2590d3"
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
  sources = ["source.hyperv-iso.alma"]
}