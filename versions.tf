terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">= 2.69.0"
            configuration_aliases = [ azurerm.core ]
        }
        chef = {
            source = "terrycain/chef"
        }
        commandpersistence = {
            source = "terrycain/commandpersistence"
            version = "1.1.0"
        }
    }
    required_version = ">= 0.13"
}
