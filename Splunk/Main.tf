//  _______                   __                       ____        _ _     _ 
// |__   __|                 / _|                     |  _ \      (_) |   | |
//    | | ___ _ __ _ __ __ _| |_ ___  _ __ _ __ ___   | |_) |_   _ _| | __| |
//    | |/ _ \ '__| '__/ _` |  _/ _ \| '__| '_ ` _ \  |  _ <| | | | | |/ _` |
//    | |  __/ |  | | | (_| | || (_) | |  | | | | | | | |_) | |_| | | | (_| |
//    |_|\___|_|  |_|  \__,_|_| \___/|_|  |_| |_| |_| |____/ \__,_|_|_|\__,_|
//                                                                           
//                                                                           
// This file builds the base infrastructure per the deails below largey this file
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

  	  tags {
    costcode = "${var.costcode}"
		environment = "${var.environment}"
		product = "${var.product}"
  }
}

###########################################################
# Create\Update the SNET for the machines to be joined to #
###########################################################

resource "azurerm_subnet" "snet" {
  name                 = "${var.subnet_name}"
  resource_group_name  = "${var.vnet_resource_group}"
  virtual_network_name = "${var.virtual_network_name}"
  address_prefix       = "${var.subnet_prefix}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
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

#########################
# Default Inbound Rules #
#########################

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

  	resource "azurerm_network_security_rule" "nsg7" {
	  name                        = "IBA_NESSUS-ALL"
	  priority                    = 300
	  direction                   = "Inbound"
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "*"
	  destination_port_range      = "*"
	  source_address_prefix       = "10.0.3.213/32"
	  destination_address_prefix  = "*"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

	resource "azurerm_network_security_rule" "aad21" {
	  name                        = "IBD_AADDC"
	  priority                    = 130
	  direction                   = "Inbound"
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "*"
	  destination_port_range      = "*"
	  source_address_prefix       = "10.128.120.48/29"
	  destination_address_prefix  = "*"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

##########################
# Default Outbound Rules #
##########################

	resource "azurerm_network_security_rule" "nsg2" {
	  name                        = "OBA_ALL_VNET"
	  priority                    = 4002
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "*"
	  destination_port_range      = "*"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "*"
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

# Rules for AD authentication and domain joining

		resource "azurerm_network_security_rule" "aad1" {
	  name                        = "OBA_ADSNET1-135RPC"
	  priority                    = 110
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "*"
	  destination_port_range      = "135"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.53"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad2" {
	  name                        = "OBA_ADSNET1-464KERB"
	  priority                    = 111
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "*"
	  source_port_range           = "*"
	  destination_port_range      = "464"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.53"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad3" {
	  name                        = "OBA_ADSNET1-389LDAP"
	  priority                    = 112
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "*"
	  source_port_range           = "*"
	  destination_port_range      = "389"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.53"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad4" {
	  name                        = "OBA_ADSNET1-3268LDAPGC"
	  priority                    = 113
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "*"
	  destination_port_range      = "3268"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.53"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad5" {
	  name                        = "OBA_ADSNET1-53DNS"
	  priority                    = 114
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "*"
	  source_port_range           = "*"
	  destination_port_range      = "53"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.53"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad6" {
	  name                        = "OBA_ADSNET1-88KERB"
	  priority                    = 115
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "*"
	  source_port_range           = "*"
	  destination_port_range      = "88"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.53"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad7" {
	  name                        = "OBA_ADSNET1-445SMB"
	  priority                    = 116
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "*"
	  source_port_range           = "*"
	  destination_port_range      = "445"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.53"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad8" {
	  name                        = "OBA_ADSNET1-DYNAMIC"
	  priority                    = 117
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "*"
	  source_port_range           = "*"
	  destination_port_range      = "49152-65535"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.53"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad9" {
	  name                        = "OBA_ADSNET1-123NTP"
	  priority                    = 118
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "Udp"
	  source_port_range           = "*"
	  destination_port_range      = "123"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.53"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad10" {
	  name                        = "OBA_ADSNET2-135RPC"
	  priority                    = 119
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "*"
	  destination_port_range      = "135"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.54"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad11" {
	  name                        = "OBA_ADSNET2-464KERB"
	  priority                    = 120
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "*"
	  source_port_range           = "*"
	  destination_port_range      = "464"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.54"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad12" {
	  name                        = "OBA_ADSNET2-389LDAP"
	  priority                    = 121
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "*"
	  source_port_range           = "*"
	  destination_port_range      = "389"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.54"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad13" {
	  name                        = "OBA_ADSNET2-3268LDAPGC"
	  priority                    = 122
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "*"
	  destination_port_range      = "3268"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.54"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad14" {
	  name                        = "OBA_ADSNET2-53DNS"
	  priority                    = 123
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "*"
	  source_port_range           = "*"
	  destination_port_range      = "53"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.54"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad15" {
	  name                        = "OBA_ADSNET2-88KERB"
	  priority                    = 124
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "*"
	  source_port_range           = "*"
	  destination_port_range      = "88"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.54"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad16" {
	  name                        = "OBA_ADSNET2-445SMB"
	  priority                    = 125
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "*"
	  destination_port_range      = "445"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.54"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad17" {
	  name                        = "OBA_ADSNET2-DYNAMIC"
	  priority                    = 126
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "*"
	  destination_port_range      = "49152-65535"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.54"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad18" {
	  name                        = "OBA_ADSNET2-123NTP"
	  priority                    = 127
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "Udp"
	  source_port_range           = "*"
	  destination_port_range      = "123"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.54"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad19" {
	  name                        = "OBA_ADSNET1-636LDAPS"
	  priority                    = 128
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "*"
	  source_port_range           = "*"
	  destination_port_range      = "636"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.53"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "aad20" {
	  name                        = "OBA_ADSNET2-636LDAPS"
	  priority                    = 129
	  direction                   = "Outbound"
	  access                      = "Allow"
	  protocol                    = "*"
	  source_port_range           = "*"
	  destination_port_range      = "636"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "10.128.120.54"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}


###############################
# Non standard approved rules #
###############################

	resource "azurerm_network_security_rule" "nsg4" {
	  name                        = "IBA_SSH_MGMT"
	  priority                    = 305
	  direction                   = "Inbound"
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "*"
	  destination_port_range      = "22"
	  source_address_prefix       = "10.128.121.64/28"
	  destination_address_prefix  = "*"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "nsg5" {
	  name                        = "IBA_SearchHeads"
	  priority                    = 310
	  direction                   = "Inbound" 
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "*"
	  destination_port_range      = "8089"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "*"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

		resource "azurerm_network_security_rule" "nsg6" {
	  name                        = "IBA_SplunkAgentCommunication"
	  priority                    = 315
	  direction                   = "Inbound" 
	  access                      = "Allow"
	  protocol                    = "Tcp"
	  source_port_range           = "*"
	  destination_port_range      = "9996"
	  source_address_prefix       = "*"
	  destination_address_prefix  = "*"
	  resource_group_name         = "${azurerm_resource_group.rg.name}"
	  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
	}

#################
# End of script #
#################