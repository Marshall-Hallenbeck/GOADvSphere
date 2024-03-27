packer {
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = "~> 1"
    }
  }
}

variable "vsphere_server" {}
variable "vsphere_username" {}
variable "vsphere_password" {}
variable "vsphere_esxi_host" {}
variable "vsphere_datastore" {}
variable "ssh_username" {}
variable "ssh_password" {}
variable "http_file_host" {}
variable "ubuntu_iso" {}


source "vsphere-iso" "ubuntu" {
  convert_to_template  = true
  CPUs                 = 4
  RAM                  = 4096
  RAM_reserve_all      = true
  shutdown_command = "echo '${var.ssh_password}' | sudo -S -E shutdown -P now"
  shutdown_timeout = "5m"
  http_ip          = "${var.http_file_host}"
  http_directory   = "packer/ubuntu/files/"
  // http_port_min    = "8100" # defaults to 8100
  // http_port_max    = "8299" # defaults to 9000

  boot_wait        = "2s"
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ---",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]
  disk_controller_type  = ["lsilogic-sas"]
  guest_os_type        = "ubuntu64Guest"
  host                 = "${var.vsphere_esxi_host}"
  insecure_connection  = true
  folder               = "GOAD/templates/ubuntu2204/" # folder the template is put into
  datastore            = "${var.vsphere_datastore}"

  # Use this if you want to use an ISO that is already in the datastore
  # "[Datastore] Linux/Ubuntu/ubuntu-22.04.3-live-server-amd64.iso"
  iso_paths = [
    "${var.ubuntu_iso}"
  ]

  # Use this if you want to download the ISO via HTTP
  // iso_url              = "http://lab.malicious.group/ubuntu-22.04.iso"
  // iso_checksum         = "5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"

  # we connect to the VM Network for the Packer build so it can get an IP address for setup
  network_adapters {
    network   = "VM Network"
    network_card = "vmxnet3"
  }
  network_adapters {
    network      = "GOAD"
    network_card = "vmxnet3"
  }
  password     = "${var.vsphere_password}"
  ssh_port     = "22"
  ssh_username = "${var.ssh_username}"
  ssh_password = "${var.ssh_password}"
  ssh_timeout  = "120m"
  username       = "${var.vsphere_username}"
  vcenter_server = "${var.vsphere_server}"
  vm_name        = "ubuntu"
  storage {
    disk_size             = 32768
    disk_thin_provisioned = true
  }
}

build {
  sources = ["source.vsphere-iso.ubuntu"]

  provisioner "file" {
    source = "packer/ubuntu/files/goad-cookbook.zip"
    destination = "/home/ansible/cookbook.zip"
  }
}
