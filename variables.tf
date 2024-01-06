variable "vsphere_user" {
    description = "User ID for vSphere"
    type        = string
}

variable "vsphere_password" {
    description = "Password for vSphere"
    type        = string
    sensitive   = true
}

variable "vm_cluster_name" {
  default = "Gaborone-Production"
}

variable "cpu_count" {
    description = "vCPU count for the VMs"
    type        = number
    default     = 2
}

variable "vm_count" {
  description = "number of VMs to create"
  type = number
  default = 1
  validation {
    condition = var.vm_count >= 1
    error_message = "Must be 1 or more."
  }
}

variable "cdrom_image" {
    description = "Path to CDROM image file"
    type        = string
    default     = "ipxe-efi.iso"
}

variable "mem_size" {
    description = "Memory size for the VMs, in MB"
    type        = number
    default     = 4092
}

variable "vsphere_folder_name" {
    description = "VMs and Templates folder in which to place the VMs"
    type        = string
    default     = "Monitoring"
}

variable "ld4_virtual_machines" {
    default = {
        "k8sm01.bophelo.co.bw" = {
            name     = "k8sm01"
            ipv4addr = "192.168.1.40"
            netmask  = "255.255.255.0"
            gateway  = "192.168.1.254"
            dns      = "192.168.1.201"
            mem_size = "2048"
            cpu      = "2"
            disks     = [{
                name        = "disk0"
                size        = 32
                unit_number = 0
            }]
        }
    }
}

variable "maun_virtual_machines" {
}