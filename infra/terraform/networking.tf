resource "azurerm_virtual_network" "kg-opencti-vnet-test" {
  name                = "kg-opencti-vnet-test"
  address_space       = ["10.0.0.0/20"]
  location            = azurerm_resource_group.kg-opencti-test.location
  resource_group_name = azurerm_resource_group.kg-opencti-test.name
}

resource "azurerm_subnet" "opencti-subnet-test" {
  name                 = "opencti-subnet-test"
  resource_group_name  = azurerm_resource_group.kg-opencti-test.name
  virtual_network_name = azurerm_virtual_network.kg-opencti-vnet-test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_private_dns_zone" "opencti-private-dns-test" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = azurerm_resource_group.kg-opencti-test.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "opencti-private-virtual-network-dns-test" {
  name                  = "opencti-private-virtual-network-dns-test"
  resource_group_name   = azurerm_resource_group.kg-opencti-test.name
  private_dns_zone_name = azurerm_private_dns_zone.opencti-private-dns-test.name
  virtual_network_id    = azurerm_virtual_network.kg-opencti-vnet-test.id
}
