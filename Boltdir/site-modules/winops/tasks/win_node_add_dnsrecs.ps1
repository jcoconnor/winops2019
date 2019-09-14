param ($base_node_name, $count)

# Script to create the Azure DNS Records we need.
# These need the Powershell AZ module to be loaded. 

$ZoneName = "winops2019.automationdemos.com"
$RgName = "winops2019"
$SubscriptionID = $env:azure_subscription_id

for ($i = 1; $i -le $count; $i++){

    $IpAddressRef = "{0}-{1:d2}-publicip"  -f $base_node_name,$i
    $AliasName = "{0}-{1:d2}"  -f $base_node_name,$i
    
    Write-Output "Working on $IpAddressRef for $AliasName"
    New-AzDnsRecordSet -RecordType A -ZoneName $ZoneName `
                       -ResourceGroupName $RgName `
                       -name $AliasName `
                       -TargetResourceId "/subscriptions/$SubscriptionID/resourceGroups/$RgName/providers/Microsoft.Network/publicIPAddresses/$IpAddressRef"

}



