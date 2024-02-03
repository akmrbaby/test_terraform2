// VNet：手動管理
data "azurerm_virtual_network" "common" {
  name                = "vnet-${var.project}-${var.env}-${var.location}-001"
  resource_group_name = data.azurerm_resource_group.rg.name
  //location = data.azurerm_resource_group.rg.location // location を入れるとエラーになる
  //address_space = ["192.168.0.0/16"] // address_space を入れるとエラーになる
}

// サブネット：terraform管理
resource "azurerm_subnet" "subnet1" {
  name                 = "snet-${var.project}-${var.env}-${var.location}-001"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.common.name
  address_prefixes     = ["192.168.1.0/24"]
}

// AppService の VNet 統合用
resource "azurerm_subnet" "app_integration" {
  name                 = "snet-${var.project}-${var.env}-${var.location}-002-appservice"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.common.name
  address_prefixes     = ["192.168.2.0/24"]
   delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_subnet" "app_pep" {
  name                 = "snet-${var.project}-${var.env}-${var.location}-003-appservice"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.common.name
  address_prefixes     = ["192.168.3.0/24"]
}

resource "azurerm_private_dns_zone" "app" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnszonelink" {
  name = "dnszonelink"
  resource_group_name = data.azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.app.name
  virtual_network_id = data.azurerm_virtual_network.common.id
}