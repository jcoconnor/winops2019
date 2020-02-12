# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    count               = var.nic_count
    name                = format("%s-%02d-publicip", var.inst_name, count.index + 1)
    location            = var.region
    resource_group_name = var.resource_group_name
    allocation_method   = "Static"
    domain_name_label   = format("%s-%02d-vm", var.inst_name, count.index + 1)

    tags = {
        environment = var.environment
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    count                     = var.nic_count
    name                      = format("%s-%02d-nic", var.inst_name, count.index + 1)
    location                  = var.region
    resource_group_name       = var.resource_group_name
    network_security_group_id = var.nsg_id

    ip_configuration {
        primary                       = true
        name                          = format("%s-%02d-publicip", var.inst_name, count.index + 1)
        subnet_id                     = var.subnet_id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip[count.index].id
    }

    tags = {
        environment = var.environment
    }
}

