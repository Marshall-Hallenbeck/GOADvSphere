# Uncomment these two resources if you want terraform to completely manage your vSwitch and Port Group
# resource "vsphere_host_virtual_switch" "vswitch_LAN" {
#   host_system_id      = data.vsphere_host.esxi.id
#   name                = "vSwitch1"
#   network_adapters    = ["vmnic1"]
#   active_nics         = ["vmnic1"]
# }

# resource "vsphere_host_port_group" "GOAD" {
#   name                = "GOAD"
#   host_system_id      = data.vsphere_host.esxi.id
#   virtual_switch_name = vsphere_host_virtual_switch.vswitch_LAN.name
#   depends_on          = [vsphere_host_virtual_switch.vswitch_LAN]
# }

resource "vsphere_host_port_group" "GOAD" {
  name                = "GOAD"
  host_system_id      = data.vsphere_host.esxi.id
  virtual_switch_name = "vSwitch1"  // directly use the name of the existing vSwitch
}

# Uncomment this resource if you want terraform to completely manage your compute cluster
# resource "vsphere_compute_cluster" "compute_cluster" {
#   name                = "GOAD_Cluster"
#   datacenter_id       = data.vsphere_datacenter.dc.id
# }

resource "terraform_data" "pfsense_builder" {
  triggers_replace = {
    vsphere_server   = var.vsphere_server
    vsphere_username = var.vsphere_username
    vsphere_password = var.vsphere_password
  }
  depends_on = [
    vsphere_host_port_group.GOAD,
  ]
  provisioner "local-exec" {
    command = local.build_pfsense_windows
    working_dir = abspath("../../")
    interpreter = ["PowerShell", "-Command"]
  }
}

resource "terraform_data" "ubuntu_builder" {
  triggers_replace = {
    vsphere_server   = var.vsphere_server
    vsphere_username = var.vsphere_username
    vsphere_password = var.vsphere_password
  }
  depends_on = [
    vsphere_host_port_group.GOAD,
    terraform_data.pfsense_builder
  ]
  provisioner "local-exec" {
    command = local.build_ubuntu_windows
    working_dir = abspath("../../")
    interpreter = ["PowerShell", "-Command"]
  }
}

resource "terraform_data" "windows_2016_builder" {
  triggers_replace = {
    vsphere_server   = var.vsphere_server
    vsphere_username = var.vsphere_username
    vsphere_password = var.vsphere_password
  }
  depends_on = [
    vsphere_host_port_group.GOAD,
    terraform_data.pfsense_builder
  ]
  provisioner "local-exec" {
    command = local.build_windows2016_windows
    working_dir = abspath("../../")
    interpreter = ["PowerShell", "-Command"]
  }
}

resource "terraform_data" "windows_2019_builder" {
  triggers_replace = {
    vsphere_server   = var.vsphere_server
    vsphere_username = var.vsphere_username
    vsphere_password = var.vsphere_password
  }
  depends_on = [
    vsphere_host_port_group.GOAD,
    terraform_data.pfsense_builder
  ]
  provisioner "local-exec" {
    command = local.build_windows2019_windows
    working_dir = abspath("../../")
    interpreter = ["PowerShell", "-Command"]
  }
}
