# Module Outputs

output "subnet_id" {
    value = azurerm_subnet.myterraformsubnet.id
}

output "nsg_id" {
    value = azurerm_network_security_group.myterraformnsg.id
}
