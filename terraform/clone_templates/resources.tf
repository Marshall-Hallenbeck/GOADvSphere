resource "random_string" "administrator_password" {
  length = 10
  special = false
}
variable "server_2019_instances" {
  default = {
    "DC01"  = { name = "DC-01", ip_address = "192.168.56.10" }
    "DC02"  = { name = "DC-02", ip_address = "192.168.56.11" }
    "SRV02" = { name = "SRV-02", ip_address = "192.168.56.22" }
  }
}
variable "server_2016_instances" {
  default = {
    "DC03"  = { name = "DC-03", ip_address = "192.168.56.12" }
    "SRV03" = { name = "SRV-03", ip_address = "192.168.56.23" }
  }
}
resource "vsphere_virtual_machine" "ubuntu-jumpbox" {
  depends_on       = [
    data.vsphere_virtual_machine.ubuntu_template,
    vsphere_virtual_machine.pfsense,
    vsphere_virtual_machine.vms-2016,
    vsphere_virtual_machine.vms-2019
  ]
  name             = "Ubuntu"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = data.vsphere_virtual_machine.ubuntu_template.num_cpus
  memory           = data.vsphere_virtual_machine.ubuntu_template.memory
  guest_id         = data.vsphere_virtual_machine.ubuntu_template.guest_id
  scsi_type        = data.vsphere_virtual_machine.ubuntu_template.scsi_type
  wait_for_guest_net_routable = false

  network_interface {
    network_id   = data.vsphere_network.VM_Network.id
    adapter_type = "vmxnet3"
  }
  network_interface {
    network_id   = data.vsphere_network.GOAD.id
    adapter_type = "vmxnet3"
  }
  disk {
    label            = "disk0"
    size             = 32768
    thin_provisioned = true
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.ubuntu_template.id
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt install -y python3 python3-pip unzip net-tools",
      "sudo pip3 install ansible-core==2.12.6",
      "sudo pip3 install pywinrm",
      "unzip /home/ansible/cookbook.zip",
      "cd ansible && ansible-galaxy install -r requirements.yml",
    ]
    connection {
      type        = "ssh"
      host        = self.default_ip_address
      user        = "ansible"
      password    = "ansible"
    }
  }
}
resource "vsphere_virtual_machine" "pfsense" {
  depends_on       = [data.vsphere_virtual_machine.pfsense_template]
  name             = "pfSense"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = data.vsphere_virtual_machine.pfsense_template.num_cpus
  memory           = data.vsphere_virtual_machine.pfsense_template.memory
  guest_id         = data.vsphere_virtual_machine.pfsense_template.guest_id
  scsi_type        = data.vsphere_virtual_machine.pfsense_template.scsi_type
  wait_for_guest_net_routable = false

  network_interface {
    network_id   = data.vsphere_network.GOAD.id
    adapter_type = "vmxnet3"
  }
  network_interface {
    network_id   = data.vsphere_network.VM_Network.id
    adapter_type = "vmxnet3"
    mac_address = "00:50:56:AE:B0:0B" # set up static MAC so we can set a static route on our LAN router, and it will get its reserved IP from DHCP
  }
  disk {
    label            = "disk0"
    size             = 32768
    thin_provisioned = true
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.pfsense_template.id
  }
}
resource "vsphere_virtual_machine" "vms-2019" {
  for_each         = var.server_2019_instances
  depends_on       = [
    data.vsphere_virtual_machine.server2019_template, 
    vsphere_virtual_machine.pfsense
  ]
  name             = "${each.value.name}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = data.vsphere_virtual_machine.server2019_template.num_cpus
  memory           = data.vsphere_virtual_machine.server2019_template.memory
  guest_id         = data.vsphere_virtual_machine.server2019_template.guest_id
  scsi_type        = data.vsphere_virtual_machine.server2019_template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.GOAD.id
    adapter_type = "vmxnet3"
  }
  disk {
    label            = "disk0"
    size             = 51200
    thin_provisioned = true
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.server2019_template.id
    timeout = "120"

    customize {
      windows_options {
        computer_name  = each.value.name
        admin_password = random_string.administrator_password.result
      }
      network_interface {
        ipv4_address    = each.value.ip_address
        ipv4_netmask    = "24"
      }
      dns_server_list = ["192.168.56.1", "127.0.0.1"]
      ipv4_gateway = "192.168.56.1"
    }
  }
}
resource "vsphere_virtual_machine" "vms-2016" {
  for_each         = var.server_2016_instances
  depends_on       = [
    data.vsphere_virtual_machine.server2016_template,
    vsphere_virtual_machine.pfsense
  ]
  name             = "${each.value.name}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = data.vsphere_virtual_machine.server2016_template.num_cpus
  memory           = data.vsphere_virtual_machine.server2016_template.memory
  guest_id         = data.vsphere_virtual_machine.server2016_template.guest_id
  scsi_type        = data.vsphere_virtual_machine.server2016_template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.GOAD.id
    adapter_type = "vmxnet3"
  }
  disk {
    label            = "disk0"
    size             = 51200
    thin_provisioned = true
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.server2016_template.id
    timeout = "120"

    customize {
      windows_options {
        computer_name  = each.value.name
        admin_password = random_string.administrator_password.result
      }
      network_interface {
        ipv4_address    = each.value.ip_address
        ipv4_netmask    = "24"
      }
      dns_server_list = ["192.168.56.1", "127.0.0.1"]
      ipv4_gateway = "192.168.56.1"
    }
  }
}
resource "null_resource" "run_ansible" {
  depends_on = [vsphere_virtual_machine.ubuntu-jumpbox]
  triggers = {
    vm_id = vsphere_virtual_machine.ubuntu-jumpbox.id
  }
  provisioner "remote-exec" {
    inline = [
      "sudo ifconfig ens224 up",
      "sudo dhclient ens224",
      "export ANSIBLE_COMMAND=\"ansible-playbook -i ../ad/GOAD/data/inventory -i ../ad/GOAD/providers/vsphere/inventory\"",
      "cd ansible && chmod +x ./scripts/provision.sh && ./scripts/provision.sh"
    ]
    connection {
      type     = "ssh"
      host     = vsphere_virtual_machine.ubuntu-jumpbox.default_ip_address
      user     = "ansible"
      password = "ansible"
    }
  }
}