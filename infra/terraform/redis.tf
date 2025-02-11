resource "azurerm_redis_cache" "opencti-redis-cache-test" {
    name                = "opencti-redis-cache-test"
    location            = azurerm_resource_group.kg-opencti-test.location
    resource_group_name = azurerm_resource_group.kg-opencti-test.name
    capacity            = 0
    family              = "C"
    sku_name            = "Basic"
    minimum_tls_version = "1.2"

    redis_configuration {
        maxmemory_policy = "allkeys-lru"
    }
    public_network_access_enabled = false
}

resource "azurerm_private_endpoint" "opencti-redis-cache-test-pe" {
  name                = "opencti-redis-cache-test-pe"
  location            = azurerm_resource_group.kg-opencti-test.location
  resource_group_name = azurerm_resource_group.kg-opencti-test.name
  subnet_id           = azurerm_subnet.opencti-subnet-test.id

  private_service_connection {
    name                           = "opencti-redis-cache-test-privateserviceconnection"
    private_connection_resource_id = azurerm_redis_cache.opencti-redis-cache-test.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }
}

resource "azurerm_private_dns_a_record" "opencti-redis-cache-test-dns-record" {
  name                = "opencti-redis-cache-test-dns-record"
  zone_name           = azurerm_private_dns_zone.opencti-private-dns-test.name
  resource_group_name = azurerm_resource_group.kg-opencti-test.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.opencti-redis-cache-test-pe.private_service_connection[0].private_ip_address]
}