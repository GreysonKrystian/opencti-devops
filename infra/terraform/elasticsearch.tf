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
    name                          = "internal"
    subnet_id                     = azurerm_subnet.opencti-subnet-test.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }

  dynamic "ip_configuration" {
    for_each = var.debug ? [1] : []
    content {
      name                          = "public"
      subnet_id                     = azurerm_subnet.opencti-subnet-test.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.opencti-es-pip-test[0].id
      primary                       = false
    }
  }
}

resource "azurerm_network_interface_security_group_association" "opencti-es-nic-nsg-association" {
  network_interface_id      = azurerm_network_interface.opencti-es-nic-test.id
  network_security_group_id = azurerm_network_security_group.opencti-es-nsg-test.id
}

resource "azurerm_public_ip" "opencti-es-pip-test" {
  count               = var.debug ? 1 : 0
  name                = "opencti-es-pip-test"
  location            = azurerm_resource_group.kg-opencti-test.location
  resource_group_name = azurerm_resource_group.kg-opencti-test.name
  allocation_method   = "Static"
}

resource "azurerm_virtual_machine" "opencti-es-vm-test" {
  name                  = "opencti-es-vm-test"
  location              = azurerm_resource_group.kg-opencti-test.location
  resource_group_name   = azurerm_resource_group.kg-opencti-test.name
  network_interface_ids = [azurerm_network_interface.opencti-es-nic-test.id]
  vm_size               = var.vm_sku

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

  provisioner "file" {
    source      = "../scripts/install-es.sh"
    destination = "/tmp/install-es.sh"

    connection {
      type        = "ssh"
      user        = var.admin_username
      password    = var.admin_password
      host        = azurerm_public_ip.opencti-es-pip-test[0].ip_address
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.admin_username
      password    = var.admin_password
      host        = azurerm_public_ip.opencti-es-pip-test[0].ip_address
    }
    inline = [
      "chmod +x /tmp/install-es.sh",
      "/tmp/install-es.sh"
    ]
  }
}

resource "azurerm_network_security_group" "opencti-es-nsg-test" {
  name                = "opencti-es-nsg-test"
  location            = azurerm_resource_group.kg-opencti-test.location
  resource_group_name = azurerm_resource_group.kg-opencti-test.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_outbound"
    priority                   = 1002
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}