resource "azurerm_public_ip" "bastion-test-pip" {
  name                = "bastion-tes-pip"
  location            = azurerm_resource_group.kg-opencti-test.location
  resource_group_name = azurerm_resource_group.kg-opencti-test.name
  allocation_method   = "Static"
  sku                 = var.bastion_sku
}

resource "azurerm_bastion_host" "opencti-bastionhost-test" {
  name                = "opencti-bastionhost-test"
  location            = azurerm_resource_group.kg-opencti-test.location
  resource_group_name = azurerm_resource_group.kg-opencti-test.name
  sku                 = var.bastion_sku

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.opencti-bastion-subnet-test.id
    public_ip_address_id = azurerm_public_ip.bastion-test-pip.id
  }
}

resource "azurerm_subnet" "opencti-bastion-subnet-test" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.kg-opencti-test.name
  virtual_network_name = azurerm_virtual_network.kg-opencti-vnet-test.name
  address_prefixes     = ["10.0.3.0/24"]
}