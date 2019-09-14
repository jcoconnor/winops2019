param ($base_node_name, $count)

# Simple Script to delete the Azure DNS Records we need.
# These need the Powershell AZ module to be loaded. 
# Assumes the azure_xxx credential vars are defined and user is logged into azure.

$ZoneName = "winops2019.automationdemos.com"
$RgName = "winops2019"

for ($i = 1; $i -le $count; $i++){

    $AliasName = "{0}-{1:d2}"  -f $base_node_name,$i
    
    Write-Output "Working on $AliasName"

    Remove-AzDnsRecordSet -RecordType A `
                          -ZoneName $ZoneName `
                          -ResourceGroupName $RgName `
                          -name $AliasName
}



