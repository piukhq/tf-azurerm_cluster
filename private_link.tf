locals {
    privatelink_zones = toset([for item in var.private_links : item.private_zone])
    # privatelink_zones = [ "postgres.database.azure.com" ]
}

resource "azurerm_private_dns_zone" "privatelink_zone" {
    for_each = local.privatelink_zones

    name = each.key
    resource_group_name = azurerm_resource_group.rg.name
    tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_zone" {
    for_each = local.privatelink_zones
    name = each.key
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.privatelink_zone[each.key].name
    virtual_network_id = azurerm_virtual_network.vnet.id
    tags = var.tags
}

resource "azurerm_private_endpoint" "privatelink" {
    for_each = { for item in var.private_links : item.name => item }

    # Probably dont need to scope these names as they're in the cluster RG but its nice to look at
  name                = "${var.cluster_name}-${each.key}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.privatelink.id
  tags = var.tags

  private_service_connection {
    name                           = "${var.cluster_name}-${each.key}"
    private_connection_resource_id = each.value["resource_id"]
    is_manual_connection           = false
    subresource_names = each.value["subresource_names"]
  }

  private_dns_zone_group {
      name = "${var.cluster_name}-${each.key}"
      private_dns_zone_ids = [ azurerm_private_dns_zone.privatelink_zone[each.value["private_zone"]].id ]
  }
}
