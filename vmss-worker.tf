locals {
    # Want it starting at 1 and inclusive of the max_pods_per_host
    pod_ip_range = range(1, var.max_pods_per_host + 1)
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
    name = "${var.cluster_name}-vmss"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    sku = var.worker_vm_size
    instances = var.worker_scaleset_size

    depends_on = [
        azurerm_lb_rule.https,
        azurerm_lb_rule.http
    ]

    admin_username = "terraform"
    admin_ssh_key {
        username = "terraform"
        public_key = file("~/.ssh/id_bink_azure_terraform.pub")
    }

    os_disk {
        caching = "ReadOnly"
        storage_account_type = "StandardSSD_LRS"
        disk_size_gb = 32
    }

    // Dynamic source image
    dynamic "source_image_reference" {
        for_each = local.ubuntu_image[var.ubuntu_version]
        content {
            publisher = source_image_reference.value["publisher"]
            offer = source_image_reference.value["offer"]
            sku = source_image_reference.value["sku"]
            version = source_image_reference.value["version"]
        }
    }
    zone_balance = true
    zones = [1, 2, 3]

    // scale_in_policy = OldestVM - Default is the default, default maintains best zone coverage

    custom_data = base64gzip(
        templatefile(
            "${path.module}/scripts/init.tmpl",
            {
                cinc_run_list = base64encode(jsonencode({ "run_list" : ["role[worker]"] })),
                cinc_data_secret = commandpersistence_cmd.databag_secret.result.secret,
                cinc_environment = chef_environment.env.name
            }
        )
    )

    // TODO terminate_notification
    // TODO automatic_instance_repair

    network_interface {
        name = "${var.cluster_name}-vmss-nic"
        primary = true
        enable_accelerated_networking = true
        enable_ip_forwarding = true

        ip_configuration {
            name = "primary"
            subnet_id = azurerm_subnet.worker.id
            primary = true
            load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.worker_pool.id]
        }

        dynamic "ip_configuration" {
            for_each = [for s in local.pod_ip_range : {
                name = format("vmss-pod-%02d", s)
            }]

            content {
                name = ip_configuration.value.name
                subnet_id = azurerm_subnet.worker.id
            }
        }
    }

    lifecycle {
        ignore_changes = [
            identity
        ]
    }
}

resource "azurerm_role_assignment" "vmss_iam" {
    for_each = var.vmss_iam

    scope = azurerm_linux_virtual_machine_scale_set.vmss.id
    role_definition_name = each.value["role"]
    principal_id = each.value["object_id"]
}
