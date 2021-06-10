provider "azurerm" {
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  features {}
}
terraform {
  backend "azurerm" {
    storage_account_name = "tstate27774"
    container_name       = "tstate"
    key                  = "key1"
    access_key           = "e/TBzrjcYB37mzPjBnQQuNDGttBKbpXgf41b3OwJ+Hidjf+SY98/MtaKWh2PDokl7xYT/G2jxk50Cuy/PP0l8Q=="
  }
}
module "resource_group" {
  source               = "../../modules/resource_group"
  resource_group       = "${var.resource_group}"
  location             = "${var.location}"
}
# Reference the AppService Module here.
module "network" {
  source                = "../../modules/network"
  location              = "${var.location}"
  application_type      = "${var.application_type}"
  resource_type         = "network"
  resource_group        = "${module.resource_group.resource_group_name}"
  virtual_network_name  = "${var.virtual_network_name}"
  address_space         = "${var.address_space}"
  address_prefix_test   = "${var.address_prefix_test}"
}

module "networksecuritygroup" {
  source                = "../../modules/networksecuritygroup"
  location              = "${var.location}"
  application_type      = "${var.application_type}"
  resource_type         = "networksecuritygroup"
  resource_group        = "${module.resource_group.resource_group_name}"
  subnet_id             = "${module.network.subnet_id_test}"
  address_prefix_test   = "${var.address_prefix_test}"
}

module "appservice" {
  source           = "../../modules/appservice"
  location         = "${var.location}"
  application_type = "${var.application_type}"
  resource_type    = "appservice"
  resource_group   = "${module.resource_group.resource_group_name}"
}

module "publicip" {
  source           = "../../modules/publicip"
  location         = "${var.location}"
  application_type = "${var.application_type}"
  resource_type    = "publicip"
  resource_group   = "${module.resource_group.resource_group_name}"
}

module "vm" {
  source           = "../../modules/vm"
  location         = "${var.location}"
  application_type = "${var.application_type}"
  resource_type    = "vm"
  resource_group   = "${module.resource_group.resource_group_name}"
  subnet_id        = "${module.network.subnet_id_test}"
  public_ip        = "${module.publicip.public_ip_address_id}"
}
