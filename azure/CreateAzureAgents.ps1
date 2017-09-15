# Login to Azure
#Login-AzureRmAccount

. .\AzureAgents.ps1


$MachineList = @(
  'WinopsDemo-54',
  'WinopsDemo-55'
)
$MachineList | % {

  $MachineName = $_.toLower()
  New-WinOps2017VM -MachineName $MachineName

  Configure-WinOps2017VM -MachineName $MachineName

}
