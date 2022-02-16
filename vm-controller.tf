resource "azurerm_network_interface" "controller" {
    name = "${var.cluster_name}-controller-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enable_accelerated_networking = false

    ip_configuration {
        name = "primary"
        subnet_id = azurerm_subnet.controller.id
        private_ip_address_allocation = "Static"
        private_ip_address = cidrhost(azurerm_subnet.controller.address_prefixes[0], 4)
        primary = true
    }
}

resource "azurerm_linux_virtual_machine" "controller" {
    depends_on = [
        commandpersistence_cmd.certs,
        azurerm_virtual_network_peering.peer,
        azurerm_virtual_network_peering.remote_peer,
    ]

    name = "${var.cluster_name}-controller"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = var.controller_vm_size
    # availability_set_id = var.controller_availability_set_id

    network_interface_ids = [
        azurerm_network_interface.controller.id
    ]

    tags = var.tags

    admin_username = "terraform"
    admin_ssh_key {
        username = "terraform"
        public_key = file("~/.ssh/id_bink_azure_terraform.pub")
    }

    os_disk {
        caching = "ReadOnly"
        storage_account_type = var.controller_storage_type
        disk_size_gb = 32
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-focal"
        sku = "20_04-lts"
        version = "latest"
    }

    custom_data = base64gzip(
        templatefile(
            "${path.module}/scripts/init_normal.tmpl",
            {
                cinc_run_list = base64encode(jsonencode({ "run_list" : ["role[controller_with_etcd]"] })),
                cinc_data_secret = commandpersistence_cmd.databag_secret.result.secret,
                cinc_environment = chef_environment.env.name
            }
        )
    )

    lifecycle {
        ignore_changes = [source_image_reference,custom_data]
    }
}
