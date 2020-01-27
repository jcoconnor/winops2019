# Configure the Microsoft Azure Provider

module "rgroup_and_net" {
  source = "../modules"

  region      = var.region
  environment = var.environment
  inst_name   = var.inst_name
  subnet      = var.subnet
}

# Create storage account for boot diagnostics
# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = module.rgroup_and_net.resource_group_name
    }
    
    byte_length = 8
}
resource "azurerm_storage_account" "mystorageaccount" {
    name                      = "diag${random_id.randomId.hex}"
    resource_group_name       = module.rgroup_and_net.resource_group_name
    location                  = var.region
    account_tier              = "Standard"
    account_replication_type  = "LRS"

    tags = {
        environment = var.environment
    }
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    count               = var.node_count
    name                = format("%s-%02d-publicip", var.inst_name, count.index + 1)
    location            = var.region
    resource_group_name = module.rgroup_and_net.resource_group_name
    allocation_method   = "Static"
    domain_name_label   = format("%s-%02d-vm", var.inst_name, count.index + 1)

    tags = {
        environment = var.environment
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    count                     = var.node_count
    name                      = format("%s-%02d-nic", var.inst_name, count.index + 1)
    location                  = var.region
    resource_group_name       = module.rgroup_and_net.resource_group_name
    network_security_group_id = module.rgroup_and_net.nsg_id

    ip_configuration {
        primary                       = true
        name                          = format("%s-%02d-publicip", var.inst_name, count.index + 1)
        subnet_id                     = module.rgroup_and_net.subnet_id
        private_ip_address_allocation = "Static"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip[count.index].id
    }

    tags = {
        environment = var.environment
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = format("%s-%02d-vm", var.inst_name, count.index + 1)
    location              = var.region
    count                 = var.node_count
    resource_group_name   = module.rgroup_and_net.resource_group_name
    network_interface_ids = [azurerm_network_interface.myterraformnic[count.index].id]
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
        storage_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
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
