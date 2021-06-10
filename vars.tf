variable resource_group_name { type = string }
variable cluster_name { type = string }
variable location { type = string }
variable tags { type = map(string) }
variable vnet_cidr { type = string }
variable eventhub_authid { type = string }

variable firewall { type = object({
    firewall_name = string
    resource_group_name = string
    ingress_priority = number
    rule_priority = number
    public_ip = string
    secure_origins = list(string)
    developer_ips = list(string)
    ingress_source = string
    ingress_http = number
    ingress_https = number
    ingress_controller = number
}) }

variable max_pods_per_host {
    type = number
    default = 30
}

variable tcp_endpoint {
    type = bool
    default = false
}
variable additional_firewall_rules {
    type = list(object({
        name = string
        source_addresses = list(string)
        destination_ports = list(string)
        destination_addresses = list(string)
        protocols = list(string)
    }))
    default = []
}

variable bifrost_version {
    type = string
    default = "4.6.3"
}

variable ubuntu_version {
    type = string
    default = "20.04"
}

variable postgres_servers {
    type = map(string)
}

variable private_dns { type = map(object({
    resource_group_name = string
    private_dns_zone_name = string
    should_register = bool
})) }

variable public_dns { type = map(object({
    resource_group_name = string
    dns_zone_name = string
})) }

variable peers { type = map(object({
    vnet_id = string
    vnet_name = string
    resource_group_name = string
})) }

variable subscription_peers { type = map(object({
    vnet_id = string
    vnet_name = string
    resource_group_name = string
})) }

# variable private_dns_link_bink_host { type = map(string) }
# variable "private_dns_link_bink_sh" {}

variable flux_environment { type = string }

variable common_keyvault {}
variable common_keyvault_sync_identity {}

variable controller_vm_size { default = "Standard_D2as_v4" }
variable worker_vm_size { default = "Standard_D4s_v4" }
variable worker_count { default = 0 }
variable worker_scaleset_size { default = 0 }
variable use_scaleset {
    type = bool
    default = false
}
variable prometheus_subnet { default = "10.4.0.0/18" }

variable private_links {
    type = list
    default = []
}

variable vmss_iam {
    type = map(object({ object_id = string, role = string }))
    default = {}
}
