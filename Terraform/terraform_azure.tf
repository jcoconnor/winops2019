# Configure the Microsoft Azure Provider
# Create a resource group if it doesn’t exist

resource "azurerm_resource_group" "myterraformgroup" {
    name     = "${var.inst_name}-rgroup"
    location = var.region

    tags = {
        environment = var.environment
    }
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                      = "diag${random_id.randomId.hex}"
    resource_group_name       = azurerm_resource_group.myterraformgroup.name
    location                  = var.region
    account_tier              = "Standard"
    account_replication_type  = "LRS"

    tags = {
        environment = var.environment
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "${var.inst_name}-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.region
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    tags = {
        environment = var.environment
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = var.subnet
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    count               = var.node_count
    name                = "${var.inst_name}-${count.index + 1}-publicip"
    location            = var.region
    resource_group_name = azurerm_resource_group.myterraformgroup.name
    allocation_method   = "Dynamic"

    tags = {
        environment = var.environment
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "${var.inst_name}-nsg"
    count               = var.node_count
    location            = var.region
    resource_group_name = azurerm_resource_group.myterraformgroup.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = var.environment
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "${var.inst_name}-${count.index + 1}-nic"
    count                     = var.node_count
    location                  = var.region
    resource_group_name       = azurerm_resource_group.myterraformgroup.name
    network_security_group_id = azurerm_network_security_group.myterraformnsg[count.index].id

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip[count.index].id
    }

    tags = {
        environment = var.environment
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup.name
    }
    
    byte_length = 8
}

# Error: compute.VirtualMachinesClient#CreateOrUpdate: Failure sending request: StatusCode=400 -- Original Error: Code="InvalidParameter" Message="Requested operation cannot be performed because the VM size Standard_D4_v3 does not support the storage account type Premium_LRS of disk 'myOsDisk'. Consider updating the VM to a size that supports Premium storage." Target="osDisk.managedDisk.storageAccountType"
# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "${var.inst_name}-${count.index + 1}-vm"
    location              = var.region
    count                 = var.node_count
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic[count.index].id]
    vm_size               = "Standard_D4_v3"

    storage_os_disk {
        name              = "myOsDisk"
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
        admin_username = "WinOps2019"
        admin_password = "Tfasfd993!#"
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
  name                 = "${var.inst_name}-${count.index + 1}-initscript"
  location             = var.region
  count                = var.node_count
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_machine_name = azurerm_virtual_machine.myterraformvm[count.index].name
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "hostname && uptime"
    }
SETTINGS

  tags = {
    environment = var.environment
  }
}
