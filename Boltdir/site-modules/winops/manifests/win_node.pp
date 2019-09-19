
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
  Integer $phase,
  Integer $count = 2,
  String  $absent_or_present = 'present',
) {


  # General variables applicable across all nodes.

  $subscription_id = 'c82736ee-c108-452b-8178-f548c95d18fe'
  $location         = 'uksouth'
  $rg               = 'winops2019'
  $storage_account  = 'winops2019diag'
  $nsg              = 'winops-nsg'
  $vnet             = 'winops2019-vnet'
  $subnet           = 'default'


  # Re-use basic azure resources for all VMs
  # And don't ever delete these either.
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

  range(1,$count).each | $i | {

    # Base names for this instance - pad node number out to 2 digits
    $inst_node_name = sprintf('%s-%02d', $base_node_name, $i)
    $nic_base_name  = "${inst_node_name}-nic"
    $vm_base_name   = "${inst_node_name}"
    $publicip       = "${inst_node_name}-publicip"
    $publicdns      = "${inst_node_name}-publicdns"
    $extscript      = "${inst_node_name}-script"

    # Public IP Address

    if (($phase >= 1) or ($phase == -1)) {
      azure_public_ip_address { $publicip:
        ensure              => $absent_or_present,
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
    }

    # Create multiple NIC's and VM's

    if (($phase >= 2) or ($phase == -2)) {
      azure_network_interface { $nic_base_name:
        ensure              => $absent_or_present,
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
            name       => "${inst_node_name}-nic-ipconfig"
          }]
        }
      }
    }

    if (($phase >= 3) or ($phase == -3)) {
      azure_virtual_machine { $vm_base_name:
        ensure              => $absent_or_present,
        parameters          => {},
        location            => $location,
        resource_group_name => $rg,
        properties          => {
          hardwareProfile => {
              vmSize => 'Standard_D4_v3'
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
    }

    if (($phase >= 3) or ($phase == -4)) {  # Can run in parralel for create but has to be deleted first.
      # This extension appears to be quite picky in terms of syntax.
      azure_virtual_machine_extension { $extscript :
        type                 => 'Microsoft.Compute/virtualMachines/extensions',
        extension_parameters => '',
        location             => $location,
        tags                 => {
            displayName => "${extscript}",
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
        vm_extension_name    => $extscript,
        vm_name              => $vm_base_name,
      }
    }
  }

}



# Attempt at setting the A record - think there might be a bug in the azure_arm module 
# so resorting to adding the records manually
#  -> azure_record_set { $publicdns:
#       ensure                   => $absent_or_present,
#       resource_group_name      => $rg,
#       subscription_id          => $subscription_id,
#       record_type              => 'A',
#       zone_name                => 'winops2019.automationdemos.com',
#       relative_record_set_name => $vm_base_name,
#       name                     => $vm_base_name,
#       parameters               => {},
#       properties               => {
#         targetResource => {
#           id => "/subscriptions/${subscription_id}/resourceGroups/${rg}/providers/Microsoft.Network/publicIPAddresses/${publicip}",
#         },
#         ttl            => 3600,
#       }
#     }
