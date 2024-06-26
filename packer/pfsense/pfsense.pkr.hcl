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
// variable "tailscale_preauth_key" {}
variable "ssh_username" {}
variable "ssh_password" {}
variable "http_file_host" {}
variable "pfsense_iso" {}

source "vsphere-iso" "pfsense" {
  convert_to_template  = true
  CPUs                 = 2
  RAM                  = 4096
  RAM_reserve_all      = true
  shutdown_command = "sudo /etc/rc.halt"
  shutdown_timeout = "1m"
  http_ip          = "${var.http_file_host}"
  http_directory   = "packer/pfsense/files"
  // http_port_min    = "8100"
  // http_port_max    = "8299"

  boot_command     = [
    # Initial install for 2.7.1
    "<wait30><enter>", # Accept EULA
    "<wait2><enter>", # Choose Install
    "<wait2><enter>", # Auto (ZFS) partition
    "<wait10><enter>", # Proceed with installation
    "<wait2><enter>", # Stripe - no redundancy
    "<wait2><spacebar><wait2><enter>", # select disk da0
    "<wait>Y", # Confirm installation
    "<wait15>", # Wait for base install
    "R", #Reboot the system
    "<wait180>", # Wait for reboot and boot loader; MIGHT NEED TO INCREASE THIS!
    "<wait>n<enter>", #no to vlan
    "<wait2>vmx0<enter>", # set WAN
    "<wait2>vmx1<enter>", # set LAN
    "<wait2>vmx2<enter>", # set OPT1
    "<wait2>y<enter>", # are you sure
    "<wait100>",

    # setup dynamic IP for WAN
    // "<wait>2<enter>",
    // "<wait>1<enter>",
    // "<wait>y<enter>",
    // "<wait>n<enter>",
    // "<wait><enter>",
    // "<wait>n<enter>",
    // "<wait><enter>",
    
    # setup static IP for WAN
    "<wait>2<enter>",
    "<wait>1<enter>",
    "<wait>n<enter>",
    "<wait>192.168.8.227<enter>",
    "<wait>24<enter>",
    "<wait>192.168.8.1<enter>",
    "<wait>y<enter>",
    "<wait>n<enter>",
    "<wait><enter>",
    "<wait>n<enter>",
    "<wait>n<enter>",
    "<wait><enter>",

    # Set IP assignment for GOAD LAN
    "<wait10>2<enter>",
    "<wait>2<enter>",
    "<wait>n<enter>",
    "<wait>192.168.56.1<enter>",
    "<wait>24<enter>",
    "<wait><enter>",
    "<wait>n<enter>",
    "<wait><enter>",
    "<wait>y<enter>",
    "<wait>192.168.56.100<enter>",
    "<wait>192.168.56.199<enter>",
    "<wait>n<enter>",
    "<wait><enter>",
    # Set IP assignment for SCCM LAN
    "<wait>2<enter>", // Select the option to assign a new interface
    "<wait>3<enter>", // Select OPT 1
    "<wait>n<enter>",
    "<wait>192.168.33.1<enter>", // Specify the IP address for the new interface
    "<wait>24<enter>",
    "<wait><enter>",
    "<wait>n<enter>",
    "<wait><enter>",
    "<wait>n<enter>",
    "<wait>n<enter>",
    "<wait><enter>",

    #enable sshd
    "<wait30>14<enter>",
    "<wait>y<enter>",
    "<wait5>",
    #install a few packages
    "<wait>8<enter>",
    "<wait>pkg install -y open-vm-tools-nox11 pfSense-pkg-Tailscale pfSense-pkg-sudo<enter>",
    "<wait10>reboot<enter>",
    "<wait180>",
    #setup user with sudo privileges
    "<wait>8<enter>",
    "<wait>service vmware-guestd start<enter>",
    "<wait>echo 'service vmware-guestd start' > /usr/local/etc/rc.d/vmware_service.sh<enter>",
    "<wait>chmod +x /usr/local/etc/rc.d/vmware_service.sh<enter>",
    "<wait>echo ${var.ssh_password} | pw user add ${var.ssh_username} -m -h 0<enter>",
    "<wait>pw group mod wheel -m ${var.ssh_username}<enter>",
    "<wait>chmod 660 /usr/local/etc/sudoers<enter>",
    "<wait>echo '${var.ssh_username} ALL=(ALL) NOPASSWD: ALL' >> /usr/local/etc/sudoers<enter>",
    "<wait>echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /usr/local/etc/sudoers<enter>",
    "<wait>chmod 440 /usr/local/etc/sudoers<enter>",
    "<wait>chflags schg /usr/local/etc/sudoers<enter>",
    // only needed for tailscale config
    // "<wait>curl -o /tmp/config.xml http://{{ .HTTPIP }}:{{ .HTTPPort }}/config.xml<enter>",
    // "<wait>sed 's/CHANGE_PREAUTH_KEY/${var.tailscale_preauth_key}/g' /tmp/config.xml > /cf/conf/config.xml<enter>",
    "<wait>pfSsh.php playback enableallowallwan<enter>",
  ]
  disk_controller_type  = ["lsilogic-sas"]
  guest_os_type        = "freebsd12_64Guest"
  host                 = "${var.vsphere_esxi_host}"
  insecure_connection  = true
  ip_wait_timeout      = "120m"
  datastore            = "${var.vsphere_datastore}"
  #"[TrueNAS_ISOs] pfSense-CE-2.7.2-RELEASE-amd64.iso"
  iso_paths = [
    "${var.pfsense_iso}"
  ]
  // iso_url              = "http://lab.malicious.group/pfSense-CE-2.7.1-RELEASE-amd64.iso"
  // iso_checksum         = "146d5fb7eb3dd070d898902eb418c292612363460d08bcadb43beb2670198fe2"
  folder               = "GOAD/templates/pfsense/"

  network_adapters {
    network      = "VM Network"
    network_card = "vmxnet3"
  }
  network_adapters {
    network      = "GOAD"
    network_card = "vmxnet3"
  }
  network_adapters {
    network      = "GOAD"
    network_card = "vmxnet3"
  }

  password     = "${var.vsphere_password}"
  ssh_port     = "22"
  ssh_password = "${var.ssh_password}"
  ssh_username = "${var.ssh_username}"
  storage {
    disk_size             = 32768
    disk_thin_provisioned = true
  }
  username       = "${var.vsphere_username}"
  vcenter_server = "${var.vsphere_server}"
  vm_name        = "pfsense"
}

build {
  sources = ["source.vsphere-iso.pfsense"]
}
