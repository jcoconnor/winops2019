
#
# Node pre-provision script for the WinOps Demo to install

# Registry settings for Server Manager and setting decent terminal resolution 

New-ItemProperty -Path 'Registry::HKCU\Control Panel\Desktop' -Name 'LogPixels' -Value 120 -PropertyType DWORD -Force
New-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations' -Name 'IgnoreClientDesktopScaleFactor' -PropertyType DWORD -Value 1 -Force
New-Item -Path 'Registry::HKLM\Software\Microsoft\ServerManager' -Force  -ErrorAction SilentlyContinue
New-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\ServerManager' -Name 'DoNotOpenServerManagerAtLogon' -PropertyType DWORD -Value 1 -Force

[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile("https://puppet:8140/packages/current/install.ps1", "$ENV:TEMP\install.ps1")
& "$ENV:TEMP\install.ps1" -PuppetServiceEnsure stopped -PuppetServiceEnable false main:certname=$ENV:ComputerName;

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install vscode and git
#
choco install -f -y vscode
choco install -f -y git
choco install -f -y poshgit
choco install -f -y vscode-puppet
choco install -f -y googlechrome
choco install -f -y sysinternals
choco install -f -y pdk

# Fixup the Start Menu for this account and the default user.
# 
$webClient.DownloadFile("https://raw.githubusercontent.com/jcoconnor/winops2019/production/Boltdir/site-modules/winops/files/LayoutModification.xml", "$ENV:TEMP\LayoutModification.xml")
Import-StartLayout -LayoutPath "$ENV:TEMP\LayoutModification.xml" -MountPath "$ENV:systemdrive\"

$webClient.DownloadFile("https://raw.githubusercontent.com/jcoconnor/winops2019/production/Boltdir/site-modules/winops/files/Low-SecurityPasswordPolicy.inf", "$ENV:TEMP\Low-SecurityPasswordPolicy.inf")
secedit /configure /db secedit.sdb /cfg "$ENV:TEMP\Low-SecurityPasswordPolicy.inf" /quiet

# Download user profile load script.
$webClient.DownloadFile("https://raw.githubusercontent.com/jcoconnor/winops2019/production/Boltdir/site-modules/winops/files/winops-user-setup.ps1", "$ENV:TEMP\winops-user-setup.ps1")

# Create winops account
Write-Output "Creating winops Account"
# Create a login profile for the winops account
$securePassword = ConvertTo-SecureString "WinOps2019" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential "winops", $securePassword
New-LocalUser "winops" -Password $securePassword -FullName "WinOps 2019 User" -Description "WinOps 2019 Demo User Account" -AccountNeverExpires -PasswordNeverExpires  -Verbose
Add-LocalGroupMember -Group "Administrators" -Member "winops"


Write-Output "Creating winops Profile"
Start-Process Powershell -Wait -Credential $Credential -LoadUserProfile -file "$ENV:TEMP\winops-user-setup.ps1"
