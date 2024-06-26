resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
    for_each = var.private_dns

    provider = azurerm.core

    name = "${azurerm_virtual_network.vnet.name}-${each.key}"
    resource_group_name = each.value["resource_group_name"]
    private_dns_zone_name = each.value["private_dns_zone_name"]
    virtual_network_id = azurerm_virtual_network.vnet.id
    registration_enabled = each.value["should_register"]
}

resource "azurerm_dns_a_record" "cluster_ingress_subdomains" {
    for_each = toset(var.cluster_ingress_subdomains)

    provider = azurerm.core

    name = "${each.value}.${var.cluster_name}.uksouth"
    zone_name = var.public_dns["bink_sh"].dns_zone_name
    resource_group_name = var.public_dns["bink_sh"].resource_group_name
    ttl = 300
    records = [var.firewall.public_ip]
}

resource "azurerm_dns_caa_record" "cluster_ingress_subdomains" {
    for_each = toset(var.cluster_ingress_subdomains)

    provider = azurerm.core

    name = "${each.value}.${var.cluster_name}.uksouth"
    zone_name = var.public_dns["bink_sh"].dns_zone_name
    resource_group_name = var.public_dns["bink_sh"].resource_group_name
    ttl = 300

    record {
        flags = 0
        tag = "issue"
        value = "letsencrypt.org"
    }

    record {
        flags = 0
        tag = "issuewild"
        value = ";"
    }

    record {
        flags = 0
        tag = "iodef"
        value = "mailto:devops@bink.com"
    }
}

resource "azurerm_dns_a_record" "base_record" {
    provider = azurerm.core

    name = "${var.cluster_name}.uksouth"
    zone_name = var.public_dns["bink_sh"].dns_zone_name
    resource_group_name = var.public_dns["bink_sh"].resource_group_name
    ttl = 300
    records = [var.firewall.public_ip]
}

resource "azurerm_dns_caa_record" "base_record" {
    provider = azurerm.core

    name = "${var.cluster_name}.uksouth"
    zone_name = var.public_dns["bink_sh"].dns_zone_name
    resource_group_name = var.public_dns["bink_sh"].resource_group_name
    ttl = 300

    record {
        flags = 0
        tag = "issue"
        value = "letsencrypt.org"
    }

    record {
        flags = 0
        tag = "issuewild"
        value = ";"
    }

    record {
        flags = 0
        tag = "iodef"
        value = "mailto:devops@bink.com"
    }
}

resource "azurerm_private_dns_zone_virtual_network_link" "pgfs" {
    name = "private.postgres.database.azure.com-to-${azurerm_resource_group.rg.name}"
    private_dns_zone_name = var.postgres_flexible_server_dns_link.name
    virtual_network_id = azurerm_virtual_network.vnet.id
    resource_group_name = var.postgres_flexible_server_dns_link.resource_group_name
}
