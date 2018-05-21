//  _______                   __                       ____        _ _     _ 
// |__   __|                 / _|                     |  _ \      (_) |   | |
//    | | ___ _ __ _ __ __ _| |_ ___  _ __ _ __ ___   | |_) |_   _ _| | __| |
//    | |/ _ \ '__| '__/ _` |  _/ _ \| '__| '_ ` _ \  |  _ <| | | | | |/ _` |
//    | |  __/ |  | | | (_| | || (_) | |  | | | | | | | |_) | |_| | | | (_| |
//    |_|\___|_|  |_|  \__,_|_| \___/|_|  |_| |_| |_| |____/ \__,_|_|_|\__,_|
//                                                                           
//                                                                           
// This file builds the infrastructure per the deails below largey this file
// will remain static and not need any changes. Please refer to the 
// variables.tf file where most of the updating is done. 
//
//

####################################
# Create\Update the resource group #
####################################

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

###########################################################
# Create\Update the SNET for the machines to be joined to #
###########################################################

resource "azurerm_subnet" "snet" {
  name                 = "${var.subnet_name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${var.virtual_network_name}"
  address_prefix       = "${var.subnet_prefix}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}

#################################################
# Create avalability set                        #
#################################################

resource "azurerm_availability_set" "avset" {
  name                         = "AMS-SPLUNK-AVSET-01"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3
  managed                      = true
}

#################################################
# Creating the NIC's to be attached to the VM's #
#################################################

resource "azurerm_network_interface" "nic" {
  name                = "PAZSPLUNK-nic00${count.index}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
	count 							= 3

  ip_configuration {
    name                          = "${count.index}"
    subnet_id                     = "${azurerm_subnet.snet.id}"
    private_ip_address_allocation = "static"
  }

	  tags {
    costcode = "${var.costcode}"
		environment = "${var.environment}"
		product = "${var.product}"
  }
}

############################
# Create the storage disks #
############################

resource "azurerm_managed_disk" "splunk" {
  name                 = "datadisk_existing"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
	count 							 = 2
}

resource "azurerm_managed_disk" "splunk1" {
  name                 = "datadisk_existing"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "4095"
	count 							 = 2
}

#####################
# Creating the VM's #
#####################

# Splunk Indexer

resource "azurerm_virtual_machine" "vm" {
  name                  = "PAZSPLUNKIND00${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  vm_size               = "Standard_E16_v3"
	count 								= 2

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name              = "PAZSPLUNKIND00${count.index}-OS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "PAZSPLUNKIND00${count.index}"
    admin_username = "${var.admin_username}"
    //admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
		ssh_keys {
			path 			= "/home/serveradmin/.ssh/authorized_keys"
			key_data 	= "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAv3ai32kRmR5m0Yip1HJTToRgan9eBxQXZ/4y62zZcyB0nJWJZDhn6Qisqo9KkOLhbDSc+OE5vq+51P/vLHnMossh4gBp0Nnos56Vq5ymvUkksWLd1QQVSxr4MeU5CI5qYCmUC3Q29qzav+ZfqCkXpGgPc0sQTI1kCTIg8CgYnlQmA0uXtg8maXff5sGiOnp60I7MnyAo76neVqCWzakGRTxSyIRPXMi/Fq1QgHQCzfQL8svOJtMvZE+tsow415PtX4Uhbiqw4/V9srznzs+ilAmjPgS0Wez1F/yM7LYK7y7UIp7/c7iSrw9KM3cQs2DVCDmG331gFfciAGvgffwlsw== rsa-key-20180112 "
		}
  }

	  tags {
    costcode = "${var.costcode}"
		environment = "${var.environment}"
		product = "${var.product}"
  }
}

# Splunk Cluster Master

resource "azurerm_virtual_machine" "vm1" {
  name                  = "PAZSPLUNKCM001"
  location              = "West Europe"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  vm_size               = "Standard_DS2_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name              = "PAZSPLUNKCM001-OS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "PAZSPLUNKCM001"
    admin_username = "${var.admin_username}"
    //admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
		ssh_keys {
			path 			= "/home/serveradmin/.ssh/authorized_keys"
			key_data 	= "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAv3ai32kRmR5m0Yip1HJTToRgan9eBxQXZ/4y62zZcyB0nJWJZDhn6Qisqo9KkOLhbDSc+OE5vq+51P/vLHnMossh4gBp0Nnos56Vq5ymvUkksWLd1QQVSxr4MeU5CI5qYCmUC3Q29qzav+ZfqCkXpGgPc0sQTI1kCTIg8CgYnlQmA0uXtg8maXff5sGiOnp60I7MnyAo76neVqCWzakGRTxSyIRPXMi/Fq1QgHQCzfQL8svOJtMvZE+tsow415PtX4Uhbiqw4/V9srznzs+ilAmjPgS0Wez1F/yM7LYK7y7UIp7/c7iSrw9KM3cQs2DVCDmG331gFfciAGvgffwlsw== rsa-key-20180112 "
		}
  }

	  tags {
    costcode = "${var.costcode}"
		environment = "${var.environment}"
		product = "${var.product}"
  }
}

############################################
# Create security group with default rules #
############################################

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.nsg_name}"
  location            = "West Europe"
  resource_group_name = "${azurerm_resource_group.rg.name}"

	  tags {
    costcode = "${var.costcode}"
		environment = "${var.environment}"
		product = "${var.product}"
  }
}

	resource "azurerm_network_security_rule" "nsg1" {
	  name                        = "IBD_All-All"
	  priority                    = 4001
	  direction                   = "Inbound"
	  access                      = "Deny"
	  protocol                    = "Tcp"
	  source_port_range           = "*"
	  destination_port_range      = "*"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "*"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

	resource "azurerm_network_security_rule" "nsg2" {
	  name                        = "OBA_ALL_VNET"
	  priority                    = 4002
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "*"
	  destination_port_range      = "*"
	  source_address_prefix       = "10.128.114.0/24"
	  destination_address_prefix  = "10.128.114.0/24"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

	resource "azurerm_network_security_rule" "nsg3" {
	  name                        = "OBD_Deny_VirtualNetwork"
	  priority                    = 4003
	  direction                   = "Outbound"
	  access                      = "Deny"
	  protocol                    = "Tcp"
	  source_port_range           = "*"
	  destination_port_range      = "*"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "VirtualNetwork"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

###############################
# Non standard approved rules #
###############################

	resource "azurerm_network_security_rule" "nsg4" {
	  name                        = "Allow_SSH"
	  priority                    = 4004
	  direction                   = "Inbound"
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "22"
	  destination_port_range      = "*"
	  source_address_prefix       = "213.86.217.90"
	  destination_address_prefix  = "*"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "nsg5" {
	  name                        = "SearchHeads"
	  priority                    = 4005
	  direction                   = "Inbound" 
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "8089"
	  destination_port_range      = "*"
	  source_address_prefix       = "213.86.217.90"
	  destination_address_prefix  = "*"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "nsg6" {
	  name                        = "SplunkAgentCommunication"
	  priority                    = 4006
	  direction                   = "Inbound" 
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "9996"
	  destination_port_range      = "*"
	  source_address_prefix       = "213.86.217.90"
	  destination_address_prefix  = "*"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

#################
# End of script #
#################