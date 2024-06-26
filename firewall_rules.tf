resource "azurerm_firewall_nat_rule_collection" "ingress" {
    provider = azurerm.core

    name = "ingress-${azurerm_resource_group.rg.name}"
    azure_firewall_name = var.firewall.firewall_name
    resource_group_name = var.firewall.resource_group_name
    priority = var.firewall.ingress_priority
    action = "Dnat"

    rule {
        name = "http"
        source_addresses = [var.firewall.ingress_source]
        destination_ports = [var.firewall.ingress_http]
        destination_addresses = [var.firewall.public_ip]
        translated_address = cidrhost(azurerm_subnet.worker.address_prefixes[0], 4)
        translated_port = "30000"
        protocols = ["TCP"]
    }
    rule {
        name = "https"
        source_addresses = [var.firewall.ingress_source]
        destination_ports = [var.firewall.ingress_https]
        destination_addresses = [var.firewall.public_ip]
        translated_address = cidrhost(azurerm_subnet.worker.address_prefixes[0], 4)
        translated_port = "30001"
        protocols = ["TCP"]
    }
    rule {
        name = "controller"
        source_addresses = var.firewall.secure_origins
        destination_ports = [var.firewall.ingress_controller]
        destination_addresses = [var.firewall.public_ip]
        translated_address = cidrhost(azurerm_subnet.controller.address_prefixes[0], 4)
        translated_port = "6443"
        protocols = ["TCP"]
    }
}

resource "azurerm_firewall_network_rule_collection" "additional" {
    count = var.additional_firewall_rules_enabled ? 1 : 0
    provider = azurerm.core

    name = "${var.cluster_name}-additional"
    azure_firewall_name = var.firewall.firewall_name
    resource_group_name = var.firewall.resource_group_name
    priority = var.firewall.ingress_priority
    action = "Allow"

    dynamic "rule" {
        for_each = var.additional_firewall_rules
        content {
            name = rule.value["name"]
            source_addresses = rule.value["source_addresses"]
            destination_ports = rule.value["destination_ports"]
            destination_addresses = rule.value["destination_addresses"]
            protocols = rule.value["protocols"]
        }
    }
}
