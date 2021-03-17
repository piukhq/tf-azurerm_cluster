terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
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
