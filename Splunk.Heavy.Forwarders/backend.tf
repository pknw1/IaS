// _____                    __                        ____             _                  _ 
// |_   _|__ _ __ _ __ __ _ / _| ___  _ __ _ __ ___   | __ )  __ _  ___| | _____ _ __   __| |
//   | |/ _ \ '__| '__/ _` | |_ / _ \| '__| '_ ` _ \  |  _ \ / _` |/ __| |/ / _ \ '_ \ / _` |
//   | |  __/ |  | | | (_| |  _| (_) | |  | | | | | | | |_) | (_| | (__|   <  __/ | | | (_| |
//   |_|\___|_|  |_|  \__,_|_|  \___/|_|  |_| |_| |_| |____/ \__,_|\___|_|\_\___|_| |_|\__,_|
//                                                                                           
// This file configures the backend shared storage file for the tfstate files. 
// The tf state file holds the configuration for each environment
//
// The only change to this file per environment is the "key" 

terraform {
  backend "azurerm" {
    storage_account_name = "terraformiaasstorage"
    container_name       = "terraform"
    key                  = "splunkHF.tfstate"
    access_key           = "3+N3d+NEOYIAiLQGhtAl4om4kJuES1PsE6bvufcZvNA+PmtVS5LbYVQagE2btn+ibmyXxSmP3mcSiEOUEPdR9w=="
  }
}
