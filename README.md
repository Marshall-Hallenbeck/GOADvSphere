# GOADvSphere
A vSphere deployment of GOADv2 - BETA version 0.2

---

# INSTALL FROM WINDOWS - BETA TESTING
## How to install
Install Packer & Terraform, and ensure they are in your PATH

Make sure you have python3 on your Windows machine, and install the **python-terraform** module.

```pip3 install python-terraform```

Setup the infrastructure by using the setup.py script.

```python3 setup.py```

The build will first create some templates from ISO, then it will use those templates to build the infrastructure. Lastly a ansible script will run from the Ubuntu jumpbox setting up all the configuration details for the GOADv2 lab.

This version of the build requires you to specify the ISOs in the configuration. The templates will be stored on the vSphere datastore and will be used to clone into the GOADv2 infrastructure.

**NOTE:**
This is a clone of the latest GOAD build (v2) from Orange Cyberdefense rebuilt for vSphere infrastructure. Their repo can be found here: https://github.com/Orange-Cyberdefense/GOAD

---

### Todo

- [x] Build the ```destroy.py``` script to cleanly tear down infrastructure
- [x] Add ELK support for Ubuntu 22.04 instead of Ubuntu 18.04
- [ ] Add logic to detect an available vmnic during vSphere vSwitch setup in ```build_templates/resources.tf``` file 
- [ ] Add option for user to select 'GOAD', 'NHA', or a custom build template during setup
- [ ] Improve the current ansible scripts to fix some stability issues
- [ ] Add a exchange 2019 ansible script to extend the GOAD network to another server running Exchange 2019
