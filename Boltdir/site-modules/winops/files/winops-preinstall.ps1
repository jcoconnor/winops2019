
#
# Node pre-provision script for the WinOps Demo to install:
# 1. Puppet
# 2. Git
# 3. Chocolatey
# 4. Vscode and extension
# 5. Download Repo
# 6. Setup useful shortcuts for demo

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

# Registry settings for Server Manager and setting decent terminal resolution 

New-ItemProperty -Path 'Registry::HKCU\Control Panel\Desktop' -Name 'LogPixels' -Value 120 -PropertyType DWORD -Force
New-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations' -Name 'IgnoreClientDesktopScaleFactor' -PropertyType DWORD -Value 1 -Force
New-Item -Path 'Registry::HKLM\Software\Microsoft\ServerManager' -Force
New-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\ServerManager' -Name 'DoNotOpenServerManagerAtLogon' -PropertyType DWORD -Value 1 -Force

# Fixup the Start Menu for this account and the default user.
# 
$webClient.DownloadFile("https://raw.githubusercontent.com/jcoconnor/winops2019/production/Boltdir/site-modules/winops/files/LayoutModification.xml", "$env:LOCALAPPDATA\Microsoft\Windows\Shell\LayoutModification.xml")
Import-StartLayout -LayoutPath "$env:LOCALAPPDATA\Microsoft\Windows\Shell\LayoutModification.xml" -MountPath "$env:systemdrive"

$webClient.DownloadFile("https://raw.githubusercontent.com/jcoconnor/winops2019/production/Boltdir/site-modules/winops/files/Low-SecurityPasswordPolicy.inf", "$ENV:TEMP\Low-SecurityPasswordPolicy.inf")
secedit /configure /db secedit.sdb /cfg "$ENV:TEMP\Low-SecurityPasswordPolicy.inf" /quiet


# Download user profile load script.
$webClient.DownloadFile("https://raw.githubusercontent.com/jcoconnor/winops2019/production/Boltdir/site-modules/winops/files/winops-user-setup.ps1", "$ENV:TEMP\winops-user-setup.ps1")

# Create winops account
Write-Output "Creating winops Account"
net user winops WinOps2019 /ADD
net user winops /active:yes
wmic useraccount where 'name = "winops"' set PasswordExpires=FALSE

# Add winops to Administrators (localised) group
$HostName=hostname
$objSID = New-Object System.Security.Principal.SecurityIdentifier ("S-1-5-32-544")
$AdminsString = (($objSID.Translate( [System.Security.Principal.NTAccount])).value).split("\")[1]
[ADSI]$Admins="WinNT://$HostName/$AdminsString,group"
$Admins.psbase.Invoke("Add",([ADSI]"WinNT://$HostName/winops").path)

# Create a login profile for the winops account
$securePassword = ConvertTo-SecureString "WinOps2019" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential "winops", $securePassword
Write-Output "Creating winops Profile"
Start-Process Powershell -Wait -Credential $Credential -LoadUserProfile -file "$ENV:TEMP\winops-user-setup.ps1"
