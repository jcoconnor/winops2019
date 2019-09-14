
# Script to create the Azure DNS Records we need.
# These need the Powershell AZ module to be loaded.

$ZoneName = "winops2019.automationdemos.com"
$RgName = "winops2019"
$SubscriptionID = $env:azure_subscription_id



$IpAddressRef = "$NodeName-publicip"

New-AzDnsRecordSet -RecordType A -ZoneName $ZoneName -ResourceGroupName $RgName -name $AliasName -TargetResourceId "/subscriptions/$SubscriptionID/resourceGroups/$RgName/providers/Microsoft.Network/publicIPAddresses/$IpAddressRef"
