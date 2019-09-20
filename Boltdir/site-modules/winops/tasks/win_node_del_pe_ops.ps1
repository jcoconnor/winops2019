param ($base_node_name, $count)

# Simple Script to create users on PE Console.

$pe_headers = @{"X-Authentication" = "$ENV:pe_master_token" ; "Content-Type" = "application/json"}

$pe_uri = "https://puppet.winops2019.automationdemos.com:4433/rbac-api/v1/users"

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# Get Hash with All Users first.

for ($i = 1; $i -le $count; $i++){
    # Loop thru list of usernames to identify user records.
    # Delete the corresponding user-id for the name

    $ops_username = "{0}_{1:d2}"  -f $base_node_name,$i
    $ops_description = "WinOps Demo {0:d2}"  -f $i
    
    Write-Output "Working on $ops_username : $ops_description"
    #$pe_ops_hash = [ordered]@{ 
    #        login = "$ops_username";
    #        email = "test@puppet.com";
    #        display_name = "$ops_description";
    #        role_ids = @(2);
    #        password = "WinOps2019"
    #}

    #$JSON = $pe_ops_hash | convertto-json -compress
    #Invoke-RestMethod -ContentType "application/json" -uri $pe_uri -Method POST -Body $JSON -Headers $pe_headers

}
