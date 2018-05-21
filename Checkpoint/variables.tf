//  _______                   __                      __      __        _       _     _           
// |__   __|                 / _|                     \ \    / /       (_)     | |   | |          
//    | | ___ _ __ _ __ __ _| |_ ___  _ __ _ __ ___    \ \  / /_ _ _ __ _  __ _| |__ | | ___  ___ 
//    | |/ _ \ '__| '__/ _` |  _/ _ \| '__| '_ ` _ \    \ \/ / _` | '__| |/ _` | '_ \| |/ _ \/ __|
//    | |  __/ |  | | | (_| | || (_) | |  | | | | | |    \  / (_| | |  | | (_| | |_) | |  __/\__ \
//    |_|\___|_|  |_|  \__,_|_| \___/|_|  |_| |_| |_|     \/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/
//                                                                                                
//                                                                                               
//                                                  
//   How to use this variable file...                                               
//
//    
//
//
//
//
//


variable "resource_group" {
  description = "The name of the resource group in which to create the virtual network."
  default = "RG-AMS-SECOPS-SPLUNK"
}

variable "vnet_resource_group" {
  description = "The name of the resource group in which contains the vnet and snet if a pre existing vnet or snet is used."
  default = "RG-AMS-IaaS"
}

variable "rg_prefix" {
  description = "The shortened abbreviation to represent your resource group that will go on the front of some resources."
  default     = "RG"
}

variable "nsg_name" {
  description = "The Network Security Group that needs to be created to control connectivity to the resources"
  default     = "AMS-SECOPS-SPLUNK-NSG"
}

#variable "hostname" {
#  description = "VM name referenced also in storage-related names."
#}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default     = "West Europe"
}

variable "virtual_network_name" {
  description = "The name for the virtual network."
  default     = "vNet-AMS-IaaS-Gateway"
}

variable "subnet_name" {
  description = "The name for the virtual network."
  default     = "sNET-AMS-OPS-GW-SUBNET-SPLUNK"
}

#variable "address_space" {
#  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
#  default     = "10.0.0.0/16"
#}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.128.120.224/27"
}

variable "storage_account_tier" {
  description = "Defines the Tier of storage account to be created. Valid options are Standard and Premium."
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Defines the Replication Type to use for this storage account. Valid options include LRS, GRS etc."
  default     = "LRS"
}

#variable "vm_size" {
#  description = "Specifies the size of the virtual machine."
#  default     = "Standard_D1"
#}

variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "RedHat"
}

variable "image_offer" {
  description = "the name of the offer (az vm image list)"
  default     = "RHEL"
}

variable "image_sku" {
  description = "image sku to apply (az vm image list)"
  default     = "7.3"
}

variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "admin_username" {
  description = "administrator user name"
  default     = "linadmin"
}

//variable "admin_password" {
//  description = "administrator password (recommended to disable password auth)"
//}

variable "costcode" {
  description = "The costcode tag that all resources need to be created with"
  default     = "core"
}

variable "environment" {
  description = "The environment tag that all resources need to be created with"
  default     = "production"
}

variable "product" {
  description = "The product tag that all resources need to be created with"
  default     = "Splunk"
}

variable "resource_count" {
  description = "The amount of resources to be created"
  default     = "2"
}