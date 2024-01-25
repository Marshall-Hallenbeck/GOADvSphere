locals {
  ansible_password     = "bQxXr88TqNf5Szh"

  build_pfsense_windows =  "..\\..\\bin\\packer.exe init ..\\..\\packer\\pfsense\\ && ..\\..\\bin\\packer.exe build -var vsphere_esxi_host=${var.vsphere_esxi_host} -var vsphere_server=${var.vsphere_server} -var vsphere_username=${var.vsphere_username} -var vsphere_password=${var.vsphere_password} -var vsphere_datastore=${var.vsphere_datastore} -var ssh_username=ansible -var ssh_password=${local.ansible_password} -var http_file_host=${var.http_file_host} -var tailscale_preauth_key=${var.tailscale_preauth_key} -force ..\\..\\packer\\pfsense\\pfsense.pkr.hcl"

  # build_ubuntu_windows = "..\\..\\bin\\packer.exe init ..\\..\\packer\\ubuntu\\ && ..\\..\\bin\\packer.exe build -var vsphere_esxi_host=${var.vsphere_esxi_host} -var vsphere_server=${var.vsphere_server} -var vsphere_username=${var.vsphere_username} -var vsphere_password=${var.vsphere_password} -var vsphere_datastore=${var.vsphere_datastore} -var ssh_username=ansible -var ssh_password=ansible -var http_file_host=${var.http_file_host} -force ../../packer/ubuntu/ubuntu.pkr.hcl"

  # build_windows2019_windows = "..\\..\\bin\\packer.exe init ..\\..\\packer\\windows2019\\ && ..\\..\\bin\\packer.exe build -var vsphere_esxi_host=${var.vsphere_esxi_host} -var vsphere_server=${var.vsphere_server} -var vsphere_username=${var.vsphere_username} -var vsphere_password=${var.vsphere_password} -var vsphere_datastore=${var.vsphere_datastore} -var winrm_password=${local.ansible_password} -force ..\\..\\packer\\windows2019\\windows2019.pkr.hcl"
  
  # build_windows2016_windows = "..\\..\\bin\\packer.exe init ..\\..\\packer\\windows2016\\ && ..\\..\\bin\\packer.exe build -var vsphere_esxi_host=${var.vsphere_esxi_host} -var vsphere_server=${var.vsphere_server} -var vsphere_username=${var.vsphere_username} -var vsphere_password=${var.vsphere_password} -var vsphere_datastore=${var.vsphere_datastore} -var winrm_password=${local.ansible_password} -force ..\\..\\packer\\windows2016\\windows2016.pkr.hcl"
}
