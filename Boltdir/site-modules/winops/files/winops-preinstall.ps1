
#
# Node pre-provision script for the WinOps Demo to install

# Registry settings for Server Manager and setting decent terminal resolution 

New-ItemProperty -Path 'Registry::HKCU\Control Panel\Desktop' -Name 'LogPixels' -Value 120 -PropertyType DWORD -Force
New-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations' -Name 'IgnoreClientDesktopScaleFactor' -PropertyType DWORD -Value 1 -Force
New-Item -Path 'Registry::HKLM\Software\Microsoft\ServerManager' -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path 'Registry::HKLM\Software\Microsoft\ServerManager' -Name 'DoNotOpenServerManagerAtLogon' -PropertyType DWORD -Value 1 -Force

New-Item -Path 'C:\WinOps2019' -ItemType Directory

[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$webClient = New-Object System.Net.WebClient

# Fixup the Start Menu for this account and the default user.
# 
$webClient.DownloadFile("https://raw.githubusercontent.com/jcoconnor/winops2019/production/Boltdir/site-modules/winops/files/LayoutModification.xml", "C:\WinOps2019\LayoutModification.xml")
Import-StartLayout -LayoutPath "C:\WinOps2019\LayoutModification.xml" -MountPath "$ENV:systemdrive\"

# Download user profile load script.
$webClient.DownloadFile("https://raw.githubusercontent.com/jcoconnor/winops2019/production/Boltdir/site-modules/winops/files/winops-user-setup.ps1", "C:\WinOps2019\winops-user-setup.ps1")
$webClient.DownloadFile("https://raw.githubusercontent.com/jcoconnor/winops2019/production/Boltdir/site-modules/winops/files/winops-user-setup.reg", "C:\WinOps2019\winops-user-setup.reg")

Write-Host "Setting startup script"
reg import C:\WinOps2019\winops-user-setup.reg

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install -f -y git
choco install -f -y poshgit

# Install Puppet
$webClient.DownloadFile("https://puppet:8140/packages/current/install.ps1", "C:\WinOps2019\install.ps1")
& "C:\WinOps2019\install.ps1" -PuppetServiceEnsure stopped -PuppetServiceEnable false main:certname=$ENV:ComputerName;

# Install Remainder of chocolatey packages
#
choco install -f -y vscode
choco install -f -y vscode-puppet
choco install -f -y googlechrome
choco install -f -y sysinternals
choco install -f -y pdk

# All Done !!!!
