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

  nic_count           = var.node_count
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = format("%s-%02d-vm", var.inst_name, count.index + 1)
    location              = var.region
    count                 = var.node_count
    resource_group_name   = module.rgroup.resource_group_name
    network_interface_ids = [module.nic_ip.network_interface[count.index].id]
    vm_size               = "Standard_D4_v3"

    storage_os_disk {
        name              = format("%s-%02d-osdisk", var.inst_name, count.index + 1)
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
    }

    os_profile {
        computer_name  = "puppet"
        admin_username = "TerraboltAdmin"
        admin_password = "PuppetIsAMaster11"
    }

    os_profile_windows_config {
        provision_vm_agent = true
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = module.storage_account.storage_uri
    }

    tags = {
        environment = var.environment
    }
}

 resource "azurerm_virtual_machine_extension" "example" {
  name                 = format("%s-%02d-initscript", var.inst_name, count.index + 1)
  count                = var.node_count
  virtual_machine_id   = azurerm_virtual_machine.myterraformvm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on           = [azurerm_virtual_machine.myterraformvm]

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; $webClient = New-Object System.Net.WebClient; $webClient.DownloadFile('https://pemaster.uksouth.cloudapp.azure.com:8140/packages/current/install.ps1', '.\\install.ps1'); .\\install.ps1 -v; Exit 0"
    }
SETTINGS

  tags = {
    environment = var.environment
  }
}
