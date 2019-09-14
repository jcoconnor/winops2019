param ($base_node_name, $count)

# Simple Script to delete the Azure storage blobs.
# These need the Powershell AZ module to be loaded. 
# Assumes the azure_xxx credential vars are defined and user is logged into azure.

$RgName = "winops2019"
$sac = Get-AzStorageAccount -ResourceGroupName $RgName -Name winops2019diag

for ($i = 1; $i -le $count; $i++){

    $blobname = "{0}-{1:d2}.vhd" -f $base_node_name,$i
    $contname = "{0}-{1:d2}-container" -f $base_node_name,$i
    Get-AzStorageBlob -Container $contname -blob $blobname -Context $sac.Context | Remove-AzStorageblob
    Get-AzStorageContainer -Container $contname  -Context $sac.Context | Remove-AzStorageContainer
}


