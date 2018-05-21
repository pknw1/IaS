terraform {
  backend "azurerm" {
    storage_account_name = "terraformiaasdevtest"
    container_name       = "terraform"
    key                  = "checkpoint.tfstate"
    access_key           = "13PtCQtl5HmlsDgRdWszBfnzEZmYrfLhUzCBBTHonfthGPFHj+VErlVaXmHchbtvCgNFMViQZBqhegGvthez7g=="
  }
}
