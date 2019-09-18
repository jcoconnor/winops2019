
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
choco install --no-progress --force --yes git
choco install --no-progress --force --yes poshgit

# Install Puppet
$webClient.DownloadFile("https://puppet:8140/packages/current/install.ps1", "C:\WinOps2019\install.ps1")
& "C:\WinOps2019\install.ps1" -PuppetServiceEnsure stopped -PuppetServiceEnable false main:certname=$ENV:ComputerName;

# Install Remainder of chocolatey packages
#
choco install --no-progress --force --yes vscode
# choco install --no-progress --force --yes vscode-puppet
choco install --no-progress --force --yes googlechrome
choco install --no-progress --force --yes pdk

# Disable IESC

$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green

# Enable IIS as well.

Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment

Enable-WindowsOptionalFeature -online -FeatureName NetFx4Extended-ASPNET45
Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45

Enable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging
Enable-WindowsOptionalFeature -Online -FeatureName IIS-LoggingLibraries
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestMonitor
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpTracing
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Security
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Performance
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools
Enable-WindowsOptionalFeature -Online -FeatureName IIS-IIS6ManagementCompatibility
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Metabase
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic

Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45

# Stop Windows Update

$WindowsUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"
$AutoUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

If(Test-Path -Path $WindowsUpdatePath) {
    Remove-Item -Path $WindowsUpdatePath -Recurse
}
Set-ItemProperty -Path $AutoUpdatePath -Name NoAutoUpdate -Value 1
Set-Service wuauserv -StartupType Disabled

# Turn off Firewall

Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# And make sure WinRm is setup
winrm quickconfig -quiet
winrm set winrm/config/service/Auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

# All Done !!!!
