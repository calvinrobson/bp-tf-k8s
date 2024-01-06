# vCenter data centres for Maun

data "vsphere_datacenter" "gaborone" {
    name = "Gaborone"
}

data "vsphere_datacenter" "maun" {
    name = "Maun"
}

# vSphere data stores

data "vsphere_datastore" "ld4_iscsi" {
    name          = "ESX01-BW-Local"
    datacenter_id = data.vsphere_datacenter.gaborone.id
}

data "vsphere_datastore" "maun_iscsi" {
    name          = "esx01-maun-local"
    datacenter_id = data.vsphere_datacenter.maun.id
}

data "vsphere_compute_cluster" "pool" {
  name          = "Gaborone-Production"
  datacenter_id = "${data.vsphere_datacenter.gaborone.id}"
}

data "vsphere_compute_cluster" "maun_pool" {
  name          = "Maun-Production"
  datacenter_id = "${data.vsphere_datacenter.maun.id}"
}

data "vsphere_network" "ld4_servers" {
    name          = "VM Network"
    datacenter_id = data.vsphere_datacenter.gaborone.id
}

data "vsphere_network" "maun_servers" {
    name          = "VM Network"
    datacenter_id = data.vsphere_datacenter.maun.id
}


# vCenter custom attributes (tags)

data "vsphere_custom_attribute" "department" {
    name = "Department"
}

data "vsphere_custom_attribute" "environment" {
    name = "Environment"
}

data "vsphere_custom_attribute" "owner" {
    name = "Owner"
}

data "vsphere_custom_attribute" "project" {
    name = "Project"
}
