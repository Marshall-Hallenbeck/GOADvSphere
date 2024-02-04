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
variable "winrm_password" {}
variable "windows2019_iso" {}

source "vsphere-iso" "windows2019" {
  convert_to_template  = true
  CPUs                 = 4
  RAM                  = 8192
  RAM_reserve_all      = true
  floppy_files = [
    "packer/windows2019/files/autounattend.xml",
    "packer/windows2019/scripts/disable-network-discovery.cmd",
    "packer/windows2019/scripts/disable-winrm.ps1",
    "packer/windows2019/scripts/enable-winrm.ps1",
    "packer/windows2019/scripts/install-vm-tools.ps1",
    "packer/windows2019/scripts/ConfigureRemotingForAnsible.ps1",
    "packer/windows2019/scripts/Install-WMF3Hotfix.ps1"
  ]
  guest_os_type        = "windows9Server64Guest"
  host                 = "${var.vsphere_esxi_host}"
  insecure_connection  = true
  communicator         = "winrm"
  ip_wait_timeout      = "120m"
  ip_settle_timeout    = "2m"
  datastore            = "${var.vsphere_datastore}"
  # "[TrueNAS_ISOs] Windows/Server 2019/17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
  iso_paths = [
    "${var.windows2019_iso}",
    "[] /vmimages/tools-isoimages/windows.iso"
  ]
  folder               = "GOAD/templates/windows2019/"

  // network_adapters {
  //   network      = "GOAD"
  //   network_card = "vmxnet3"
  // }
  # we connect to the VM Network for the Packer build so it can get an IP address for setup
  network_adapters {
    network   = "VM Network"
    network_card = "vmxnet3"
  }
  disk_controller_type  = ["lsilogic-sas"]
  password       = "${var.vsphere_password}"
  winrm_username = "ansible"
  winrm_password = "${var.winrm_password}"
  storage {
    disk_size             = 51200
    disk_thin_provisioned = true
  }
  username       = "${var.vsphere_username}"
  vcenter_server = "${var.vsphere_server}"
  vm_name        = "server2019"
}

build {
  sources = ["source.vsphere-iso.windows2019"]
}
