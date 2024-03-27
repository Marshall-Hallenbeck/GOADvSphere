locals {
  ansible_password     = "Passw0rd!"

  build_pfsense_windows = "packer init packer/pfsense/; packer build -var vsphere_esxi_host=${var.vsphere_esxi_host} -var vsphere_server=${var.vsphere_server} -var vsphere_username=${var.vsphere_username} -var vsphere_password=${var.vsphere_password} -var vsphere_datastore=${var.vsphere_datastore} -var ssh_username=ansible -var ssh_password=${local.ansible_password} -var http_file_host=${var.http_file_host} -var pfsense_iso=\"${var.pfsense_iso}\" -force packer/pfsense/pfsense.pkr.hcl"

  build_ubuntu_windows = "packer init packer/ubuntu/; packer build -var vsphere_esxi_host=${var.vsphere_esxi_host} -var vsphere_server=${var.vsphere_server} -var vsphere_username=${var.vsphere_username} -var vsphere_password=${var.vsphere_password} -var vsphere_datastore=${var.vsphere_datastore} -var ssh_username=ansible -var ssh_password=ansible -var http_file_host=${var.http_file_host} -var ubuntu_iso=\"${var.ubuntu_iso}\" -force packer/ubuntu/ubuntu.pkr.hcl"

  build_windows2019_windows = "packer init packer/windows2019/; packer build -var vsphere_esxi_host=${var.vsphere_esxi_host} -var vsphere_server=${var.vsphere_server} -var vsphere_username=${var.vsphere_username} -var vsphere_password=${var.vsphere_password} -var vsphere_datastore=${var.vsphere_datastore} -var winrm_password=${local.ansible_password} -var windows2019_iso=\"${var.windows2019_iso}\" -force packer/windows2019/windows2019.pkr.hcl"
  
  build_windows2016_windows = "packer init packer/windows2016/; packer build -var vsphere_esxi_host=${var.vsphere_esxi_host} -var vsphere_server=${var.vsphere_server} -var vsphere_username=${var.vsphere_username} -var vsphere_password=${var.vsphere_password} -var vsphere_datastore=${var.vsphere_datastore} -var winrm_password=${local.ansible_password} -var windows2016_iso=\"${var.windows2016_iso}\" -force packer/windows2016/windows2016.pkr.hcl"
}