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
  name                         = "AMS-AVSET-SPLUNK-HF-01"
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

##############################
# Creating the Load Balancer #
##############################

resource "azurerm_lb" "lb" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  name                = "${var.loadbalancer_name}"
  location            = "${var.location}"

  frontend_ip_configuration {
    name                          = "${var.frontendip_name}"
    subnet_id                     = "${azurerm_subnet.snet.id}"
    private_ip_address_allocation = "dynamic"
  }

  	tags {
    costcode = "${var.costcode}"
		environment = "${var.environment}"
		product = "${var.product}"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "BackendPool1"
}

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "${var.frontendip_name}"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}

resource "azurerm_lb_rule" "lb_rule1" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "LBRule1"
  protocol                       = "tcp"
  frontend_port                  = 9996
  backend_port                   = 9996
  frontend_ip_configuration_name = "${var.frontendip_name}"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}

resource "azurerm_lb_rule" "lb_rule2" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "LBRule2"
  protocol                       = "tcp"
  frontend_port                  = 8089
  backend_port                   = 8089
  frontend_ip_configuration_name = "${var.frontendip_name}"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 443
  interval_in_seconds = 5
  number_of_probes    = 2
}

#################################################
# Creating the NIC's to be attached to the VM's #
#################################################

resource "azurerm_network_interface" "nic" {
  name                = "PAZSPLUNKHF-nic00${count.index+1}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
	count 							= 2

  ip_configuration {
    name                          = "PAZSPLUNKHFIP-00${count.index+1}"
    subnet_id                     = "${azurerm_subnet.snet.id}"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
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
  name                 = "PAZSPLUNK-OPT-00${count.index+1}"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "100"
	count 							 = 2

	  tags {
    costcode = "${var.costcode}"
		environment = "${var.environment}"
		product = "${var.product}"
  }
}

#####################
# Creating the VM's #
#####################

###########################
# Splunk Heavy Forwarders #
###########################

resource "azurerm_virtual_machine" "vm" {
  name                  = "PAZSPLUNKHF00${count.index+1}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  vm_size               = "Standard_DS2_V2"
  availability_set_id   = "${azurerm_availability_set.avset.id}"
	count 								= 2

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
    name              = "PAZSPLUNKHF00${count.index+1}-OS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "150"
  }


  os_profile {
    computer_name  = "PAZSPLUNKHF00${count.index+1}"
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