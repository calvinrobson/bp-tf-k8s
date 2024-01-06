terraform {
  required_providers {
    dns = {
      source  = "hashicorp/dns"
      version = "3.3.2"
    }
  }
}

# Use the native Terraform vSphere provider.  User name and password for
# vCenter must be provided as variables to avoid hard coding.

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = "vcenter01.bophelo.co.bw"
  allow_unverified_ssl = true
}

# Locals.  CFL's set of standard tags are actually custom attributes in
# vCenter, not tags.

locals {
    vsphere_tags = tomap({ 
        "${data.vsphere_custom_attribute.department.id}"  = "NetEng"
        "${data.vsphere_custom_attribute.environment.id}" = "Production"
        "${data.vsphere_custom_attribute.project.id}"     = "Database"
        "${data.vsphere_custom_attribute.owner.id}"       = "CalvinR"
    })
    ipxe_file = "/ipxe/config/os/ubuntu-focal.ipxe"
}

# Our policies dictate that inventory folders should be created for services
# in vCenter, so ensure we have a folder available in each data centre.

resource "vsphere_folder" "gabs_folder" {
    path          = var.vsphere_folder_name
    type          = "vm"
    datacenter_id = data.vsphere_datacenter.gaborone.id
}

resource "vsphere_folder" "maun_folder" {
    path          = var.vsphere_folder_name
    type          = "vm"
    datacenter_id = data.vsphere_datacenter.maun.id
}

# Create VMs in LD4 data centre.  We use iPXE for the boot process and can
# use one of the more advanced features where we pass the VM's IP and hostname
# through using guestinfo variables.

resource "vsphere_virtual_machine" "ld4_vm" {
    for_each                    = var.ld4_virtual_machines
    name                        = each.value.name
    annotation                  = "MySQL Cluster"
    resource_pool_id            = data.vsphere_compute_cluster.pool.resource_pool_id
    datastore_id                = data.vsphere_datastore.ld4_iscsi.id
    num_cpus                    = each.value.cpu
    num_cores_per_socket        = each.value.cpu
    memory                      = each.value..mem_size
    guest_id                    = "ubuntu64Guest"
    hardware_version            = 19
    firmware                    = "bios"
    wait_for_guest_net_routable = false
    wait_for_guest_net_timeout  = 0
    folder                      = var.vsphere_folder_name
    custom_attributes           = local.vsphere_tags
    dynamic "disk" {
        for_each = [for disk in each.value.disks: disk]
        content {
            label = disk.value.name
            unit_number = disk.value.unit_number
            size = disk.value.size
        }
    }
    extra_config = {
        "guestinfo.ipxe.net0.ip"      = each.value.ipv4addr
        "guestinfo.ipxe.net0.netmask" = each.value.netmask
        "guestinfo.ipxe.net0.gateway" = each.value.gateway
        "guestinfo.ipxe.net0.dns"     = "192.168.1.201"
        "guestinfo.ipxe.hostname"     = "${each.value.name}"
        "guestinfo.ipxe.domain"       = "bophelo.co.bw"
        "guestinfo.ipxe.filename"     = local.ipxe_file
    }
    network_interface {
        network_id = data.vsphere_network.ld4_servers.id
    }
    cdrom {
        datastore_id = data.vsphere_datastore.ld4_iscsi.id
        path         = var.cdrom_image
    }
    depends_on = [
      vsphere_folder.gabs_folder
    ]
    lifecycle {
        ignore_changes = [
          annotation,
          hardware_version,
          custom_attributes,
          cdrom,
          tags,
          efi_secure_boot_enabled,
          extra_config
        ]
    }
}


resource "vsphere_virtual_machine" "maun_vm" {
    for_each                    = var.maun_virtual_machines
    name                        = each.value.name
    annotation                  = "MySQL Cluster"
    resource_pool_id            = data.vsphere_compute_cluster.maun_pool.resource_pool_id
    datastore_id                = data.vsphere_datastore.maun_iscsi.id
    num_cpus                    = var.cpu_count
    num_cores_per_socket        = var.cpu_count
    memory                      = var.mem_size
    guest_id                    = "ubuntu64Guest"
    hardware_version            = 17
    firmware                    = "bios"
    wait_for_guest_net_routable = false
    wait_for_guest_net_timeout  = 0
    folder                      = var.vsphere_folder_name
    custom_attributes           = local.vsphere_tags
    dynamic "disk" {
        for_each = [for disk in each.value.disks: disk]
        content {
            label = disk.value.name
            unit_number = disk.value.unit_number
            size = disk.value.size
        }
    }
    extra_config = {
        "guestinfo.ipxe.net0.ip"      = each.value.ipv4addr
        "guestinfo.ipxe.net0.netmask" = each.value.netmask
        "guestinfo.ipxe.net0.gateway" = each.value.gateway
        "guestinfo.ipxe.net0.dns"     = "192.168.1.201"
        "guestinfo.ipxe.hostname"     = "${each.value.name}"
        "guestinfo.ipxe.domain"       = "bophelo.co.bw"
        "guestinfo.ipxe.filename"     = local.ipxe_file
    }
    network_interface {
        network_id = data.vsphere_network.maun_servers.id
    }
    cdrom {
        datastore_id = data.vsphere_datastore.maun_iscsi.id
        path         = var.cdrom_image
    }
    depends_on = [
      vsphere_folder.maun_folder
    ]
    lifecycle {
        ignore_changes = [
          annotation,
          hardware_version,
          custom_attributes,
          cdrom,
          tags,
          efi_secure_boot_enabled,
          extra_config
        ]
    }
}
