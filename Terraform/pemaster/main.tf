# Configure the Microsoft Azure Provider

module "rgroup" {
  source = "../modules/rgroup"

  region      = var.region
  environment = var.environment
  inst_name   = var.inst_name
}

module "nsg_subnet" {
  source = "../modules/nsg_subnet"

  region              = var.region
  environment         = var.environment
  inst_name           = var.inst_name
  resource_group_name = module.rgroup.resource_group_name
  subnet              = var.subnet
}

module "storage_account" {
  source = "../modules/storage_account"

  region              = var.region
  environment         = var.environment
  resource_group_name = module.rgroup.resource_group_name
}

module "nic_ip" {
  source = "../modules/nic_ip"

  region              = var.region
  environment         = var.environment
  inst_name           = var.inst_name
  resource_group_name = module.rgroup.resource_group_name
  subnet_id           = module.nsg_subnet.subnet_id
  nsg_id              = module.nsg_subnet.nsg_id

  nic_count           = 1
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = format("%s-pemaster-vm", var.inst_name)
    location              = var.region
    resource_group_name   = module.rgroup.resource_group_name
    network_interface_ids = [module.nic_ip.network_interface[0].id]
    vm_size               = "Standard_D4_v3"

    storage_os_disk {
        name              = format("%s-pemaster-osdisk", var.inst_name)
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
      publisher = "cognosys"
      offer     = "centos-8-0"
      sku       = "centos-8-0"
      version   = "1.2019.0810"
    }

    os_profile {
        computer_name  = "puppet"
        admin_username = "TerraboltAdmin"
        admin_password = "PuppetIsAMaster11"
    }

    os_profile_linux_config  {
        disable_password_authentication = false
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = module.storage_account.storage_uri
    }

    tags = {
        environment = var.environment
    }
}
