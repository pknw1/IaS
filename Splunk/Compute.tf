//  _______                   __                       ____        _ _     _ 
// |__   __|                 / _|                     |  _ \      (_) |   | |
//    | | ___ _ __ _ __ __ _| |_ ___  _ __ _ __ ___   | |_) |_   _ _| | __| |
//    | |/ _ \ '__| '__/ _` |  _/ _ \| '__| '_ ` _ \  |  _ <| | | | | |/ _` |
//    | |  __/ |  | | | (_| | || (_) | |  | | | | | | | |_) | |_| | | | (_| |
//    |_|\___|_|  |_|  \__,_|_| \___/|_|  |_| |_| |_| |____/ \__,_|_|_|\__,_|
//                                                                           
//                                                                           
// This file builds the compute element per the deails below, largely this file
// will remain static and not need any changes. Please refer to the 
// variables.tf file where most of the updating is done. 
//
//

##########################
# Create avalability set #                      
##########################

resource "azurerm_availability_set" "avset" {
  name                         = "AMS-AVSET-SPLUNK-01"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true

  	tags {
    costcode = "${var.costcode}"
		environment = "${var.environment}"
		product = "${var.product}"
  }
}

#################################################
# Creating the NIC's to be attached to the VM's #
#################################################

resource "azurerm_network_interface" "nic" {
  name                = "PAZSPLUNK-nic00${count.index+1}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
	count 							= 3

  ip_configuration {
    name                          = "PAZSPLUNKIP-00${count.index+1}"
    subnet_id                     = "${azurerm_subnet.snet.id}"
    private_ip_address_allocation = "dynamic"
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
  name                 = "PAZSPLUNK-HOT-STRG-00${count.index+1}"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
	count 							 = 2

	  tags {
    costcode = "${var.costcode}"
		environment = "${var.environment}"
		product = "${var.product}"
  }
}

resource "azurerm_managed_disk" "splunk1" {
  name                 = "PAZSPLUNK-COOL-STRG-00${count.index+1}"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "4095"
	count 							 = 2

	  tags {
    costcode = "${var.costcode}"
		environment = "${var.environment}"
		product = "${var.product}"
  }
}

resource "azurerm_managed_disk" "splunk2" {
  name                 = "PAZSPLUNK-OPT-00${count.index+1}"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "100"
	count 							 = 3

	  tags {
    costcode = "${var.costcode}"
		environment = "${var.environment}"
		product = "${var.product}"
  }
}

#####################
# Creating the VM's #
#####################

# Splunk Indexer

resource "azurerm_virtual_machine" "vm" {
  name                  = "PAZSPLUNKIND00${count.index+1}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  vm_size               = "Standard_E16S_v3"
  availability_set_id   = "${azurerm_availability_set.avset.id}"
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
    name              = "PAZSPLUNKIND00${count.index+1}-OS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = "200"
  }

  //  storage_data_disk {
  //  name            = "${azurerm_managed_disk.splunk.name}"
  //  managed_disk_id = ["${element(azurerm_managed_disk.splunk.*.id, count.index)}"]
  //  create_option   = "Attach"
  //  lun             = 0
  //  disk_size_gb    = "${azurerm_managed_disk.splunk.disk_size_gb}"
  //}
//
  //  storage_data_disk {
  //  name            = "${azurerm_managed_disk.splunk1.name}"
  //  managed_disk_id = ["${element(azurerm_managed_disk.splunk1.*.id, count.index)}"]
  //  create_option   = "Attach"
  //  lun             = 1
  //  disk_size_gb    = "${azurerm_managed_disk.splunk1.disk_size_gb}"
  //}

  os_profile {
    computer_name  = "PAZSPLUNKIND00${count.index+1}"
    admin_username = "${var.admin_username}"
    //admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
		ssh_keys {
			path 			= "/home/linadmin/.ssh/authorized_keys"
			key_data 	= "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+542pdJLB90Eoqn5xyFlxBTHYpGlZYucAhD7Uwwh+y2ITZfRD2Bm1jeGjusIkRz+bwwGjKZ0n5p7uXawvH+KF3gArNw5IUiN/Ea2/NANH9exfnfrsoSZ0wI0lxtn0flPSmQefWuwArbNgMfiWTwO0l6qhE6yej/vE5GWNpPNvDyccqqKgxCJjAPqBerfxE9QNGPJoULCGL7FJTFUCv/s8kghe86VVH5I31+cfrxPqjUNnFo8P4UUnq/7rhTVZpDAgWPmMUX1ldtcSifg3ew894h51l2M+lrKuCqN+2pXVLRE6AQE1QgSeteXIFMZ2R0j3u16JNY0Ta5dam7oXffST "
		}
  }

	  tags {
    costcode = "${var.costcode}"
		environment = "${var.environment}"
		product = "${var.product}"
  }
}

#########################
# Splunk Cluster Master #
#########################

resource "azurerm_virtual_machine" "vm1" {
  name                  = "PAZSPLUNKCM001"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index+2)}"]
  availability_set_id   = "${azurerm_availability_set.avset.id}"
  vm_size               = "Standard_DS2_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

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
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = "150"
  }

  os_profile {
    computer_name  = "PAZSPLUNKCM001"
    admin_username = "${var.admin_username}"
    //admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
		ssh_keys {
			path 			= "/home/linadmin/.ssh/authorized_keys"
			key_data 	= "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+542pdJLB90Eoqn5xyFlxBTHYpGlZYucAhD7Uwwh+y2ITZfRD2Bm1jeGjusIkRz+bwwGjKZ0n5p7uXawvH+KF3gArNw5IUiN/Ea2/NANH9exfnfrsoSZ0wI0lxtn0flPSmQefWuwArbNgMfiWTwO0l6qhE6yej/vE5GWNpPNvDyccqqKgxCJjAPqBerfxE9QNGPJoULCGL7FJTFUCv/s8kghe86VVH5I31+cfrxPqjUNnFo8P4UUnq/7rhTVZpDAgWPmMUX1ldtcSifg3ew894h51l2M+lrKuCqN+2pXVLRE6AQE1QgSeteXIFMZ2R0j3u16JNY0Ta5dam7oXffST "
		}
  }

	  tags {
    costcode = "${var.costcode}"
		environment = "${var.environment}"
		product = "${var.product}"
  }
}

#################
# End of script #
#################