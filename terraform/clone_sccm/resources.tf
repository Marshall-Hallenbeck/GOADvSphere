resource "random_string" "administrator_password" {
  length = 10
  special = false
}
variable "goad_sccm_2019" {
  default = {
    "SCCM-DC"  = { name = "SCCM-DC", ip_address = "192.168.33.10", ipv4_gateway = "192.168.33.1" }
    "SCCM-MECM"  = { name = "SCCM-MECM", ip_address = "192.168.33.11", ipv4_gateway = "192.168.33.1" }
    "SCCM-MSQL" = { name = "SCCM-MSQL", ip_address = "192.168.33.12", ipv4_gateway = "192.168.33.1" }
    "SCCM-CLIENT" = { name = "SCCM-CLIENT", ip_address = "192.168.33.13", ipv4_gateway = "192.168.33.1" }
  }
}
resource "vsphere_virtual_machine" "vms-2019" {
  for_each         = var.goad_sccm_2019
  depends_on       = [
    data.vsphere_virtual_machine.server2019_template, 
    data.vsphere_virtual_machine.pfsense
  ]
  name             = "${each.value.name}"
  folder           = "GOAD/SCCM/"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = data.vsphere_virtual_machine.server2019_template.num_cpus
  memory           = data.vsphere_virtual_machine.server2019_template.memory
  guest_id         = data.vsphere_virtual_machine.server2019_template.guest_id
  scsi_type        = data.vsphere_virtual_machine.server2019_template.scsi_type
  #wait_for_guest_net_routable = false

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
      timeout = 300
      windows_options {
        computer_name  = each.value.name
        admin_password = random_string.administrator_password.result
      }
      network_interface {
        ipv4_address    = each.value.ip_address
        ipv4_netmask    = "24"
      }
      dns_server_list = ["192.168.33.1"]
      ipv4_gateway = "192.168.33.1"
    }
  }
}

resource "null_resource" "run_ansible" {
  depends_on = [data.vsphere_virtual_machine.ubuntu-jumpbox]
  triggers = {
    vm_id = data.vsphere_virtual_machine.ubuntu-jumpbox.id
  }
  provisioner "remote-exec" {
    inline = [
      "sudo ifconfig ens224 up",
      "sudo dhclient ens224",
      "export LAB=SCCM",
      "export PROVIDER=vsphere",
      #"export ANSIBLE_COMMAND=\"ansible-playbook -i /home/ansible/ad/GOAD/data/inventory -i /home/ansible/ad/GOAD/providers/vsphere/inventory\"",
      "chmod +x /home/ansible/ansible/scripts/provision.sh && /home/ansible/ansible/scripts/provision.sh"
    ]
    connection {
      type     = "ssh"
      host     = data.vsphere_virtual_machine.ubuntu-jumpbox.default_ip_address
      user     = "ansible"
      password = "ansible"
    }
  }
}