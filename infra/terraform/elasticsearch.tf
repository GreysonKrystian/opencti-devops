# resource "azurerm_elastic_cloud_elasticsearch" "opencti-elasticsearch-test" {
#   name                        = "opencti-elasticsearch-test"
#   location            = azurerm_resource_group.kg-opencti-test.location
#   resource_group_name = azurerm_resource_group.kg-opencti-test.name
#   sku_name                    = "ess-consumption-2025_Monthly"
#   elastic_cloud_email_address = "xxx"
# }

resource "azurerm_network_interface" "opencti-es-nic-test" {
  name                = "opencti-es-nic-test"
  location            = azurerm_resource_group.kg-opencti-test.location
  resource_group_name = azurerm_resource_group.kg-opencti-test.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.opencti-subnet-test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "opencti-es-vm-test" {
  name                  = "opencti-es-vm-test"
  location              = azurerm_resource_group.kg-opencti-test.location
  resource_group_name   = azurerm_resource_group.kg-opencti-test.name
  network_interface_ids = [azurerm_network_interface.opencti-es-nic-test.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "mainosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "ElasticSearchTest"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}