
# Demo script for quickly spinning up a Linux node 
# which is auto-classified with role "sample_website"
# 
# Prerequisites:
# 1. install azure_arm module (puppet install puppetlabs/azure_arm)
# 2. export the following environment variables with proper values for authentication:
#    azure_subscription_id
#    azure_tenant_id
#    azure_client_id
#    azure_client_secret


class winops::win_node (
  String $base_node_name,
) {

  #  Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; Install-Module -Name WindowsConsoleFonts -Force

  $subscription_id = 'c82736ee-c108-452b-8178-f548c95d18fe'
  $location         = 'uksouth'
  $rg               = 'winops2019'
  $storage_account  = 'winops2019diag'
  $nsg              = 'winops-ngs'
  $vnet             = 'winops2019-vnet'
  $subnet           = 'default'
  $publicip         = "${base_node_name}-publicip"
  $publicdns         = "${base_node_name}-publicdns"

  # Base names for the vm's
  $nic_base_name    = "${base_node_name}-nic"
  $vm_base_name     = "${base_node_name}-vm"

  # Re-use basic azure resources for the VMs
  azure_resource_group { $rg:
    ensure     => present,
    parameters => {},
    location   => $location
  }

  azure_storage_account { $storage_account:
    ensure              => present,
    parameters          => {},
    resource_group_name => $rg,
    account_name        => $storage_account,
    location            => $location,
    sku                 => {
      name => 'Standard_LRS',
      tier => 'Standard',
    }
  }
  # Public IP Address

  azure_public_ip_address { $publicip:
    location            => $location,
    resource_group_name => $rg,
    subscription_id     => $subscription_id,
    id                  => "/subscriptions/${subscription_id}/resourceGroups/${rg}/providers/Microsoft.Network/publicIPAddresses/${publicip}", # lint:ignore:140chars
    parameters          => {
      idleTimeoutInMinutes => '10',
    },
    properties          => {
      publicIPAllocationMethod => 'Static',
      dnsSettings              => {
        domainNameLabel => $vm_base_name,
      }
    }
  }
#  azure_record_set { $publicdns:
#    ensure              => present,
#    resource_group_name => $rg,
#    record_type         => 'A',
#    zone_name           => 'winops2019.automationdemos.com',
#    parameters          => Create,
#    properties          => {
#      ARecords => {
#        ipv4Address => 'ipv4Address',
#      },
#      TTL      => '3600',
#    }
#  }

  # Create multiple NIC's and VM's

  azure_network_interface { $nic_base_name:
    ensure              => present,
    parameters          => {},
    resource_group_name => $rg,
    location            => $location,
    properties          => {
      ipConfigurations => [{
        properties => {
          privateIPAllocationMethod => 'Dynamic',
          publicIPAddress           => {
            id         => "/subscriptions/${subscription_id}/resourceGroups/${rg}/providers/Microsoft.Network/publicIPAddresses/${publicip}", # lint:ignore:140chars
          },
          subnet                    => {
            id         => "/subscriptions/${subscription_id}/resourceGroups/${rg}/providers/Microsoft.Network/virtualNetworks/${vnet}/subnets/${subnet}", # lint:ignore:140chars
          },
        },
        name       => "${base_node_name}-nic-ipconfig"
      }]
    }
  }

  azure_virtual_machine { $vm_base_name:
    ensure              => 'present',
    parameters          => {},
    location            => $location,
    resource_group_name => $rg,
    properties          => {
      hardwareProfile => {
          vmSize => 'Standard_D4s_v3'
      },
      storageProfile  => {
        imageReference => {
          publisher => 'MicrosoftWindowsServer',
          offer     => 'WindowsServer',
          sku       => '2019-Datacenter',
          version   => 'latest'
        },
        osDisk         => {
          name         => $vm_base_name,
          createOption => 'FromImage',
          diskSizeGB   => 130,
          caching      => 'None',
          vhd          => {
            uri => "https://${$storage_account}.blob.core.windows.net/${vm_base_name}-container/${vm_base_name}.vhd"
          }
        },
        dataDisks      => []
      },
      osProfile       => {
        computerName         => $vm_base_name,
        adminUsername        => 'puppet',
        adminPassword        => 'WinOps2019',
        windowsConfiguration => {
                provisionVMAgent       => true,
                enableAutomaticUpdates => true,
        },
      },
      networkProfile  => {
        networkInterfaces => [
          {
            id      => "/subscriptions/${subscription_id}/resourceGroups/${rg}/providers/Microsoft.Network/networkInterfaces/${nic_base_name}", # lint:ignore:140chars
            primary => true
          }]
      },
    },
    type                => 'Microsoft.Compute/virtualMachines',
  }


  # This extension appears to be quite picky in terms of syntax.
  azure_virtual_machine_extension { 'script' :
    type                 => 'Microsoft.Compute/virtualMachines/extensions',
    extension_parameters => '',
    location             => $location,
    tags                 => {
        displayName => "${vm_base_name}/script",
    },
    properties           => {
      publisher          => 'Microsoft.Compute',
      type               => 'CustomScriptExtension',
      typeHandlerVersion => '1.9',
      protectedSettings  => {
        fileUris         => ['https://raw.githubusercontent.com/jcoconnor/winops2019/production/Boltdir/site-modules/winops/files/winops-preinstall.ps1'],
        commandToExecute => 'powershell -ExecutionPolicy Unrestricted -file winops-preinstall.ps1'
      },
    },
    resource_group_name  => $rg,
    subscription_id      => $subscription_id,
    vm_extension_name    => 'script',
    vm_name              => $vm_base_name,
  }
}
