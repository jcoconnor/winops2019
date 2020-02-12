
# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "${var.inst_name}-rgroup"
    location = var.region

    tags = {
        environment = var.environment
    }
}


