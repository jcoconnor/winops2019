# Script to initialise winops user account
#

# This script is run immediately post-clone to configure the machine as a clone of the template.
#
$ErrorActionPreference = "Stop"

#--- Log Session ---#
Start-Transcript -Path "C:\WinOps2019\winops-user-setup.log"

#--- FUNCTIONS ---#
function ExitScript([int]$ExitCode){
	Stop-Transcript
	exit $ExitCode
}

Copy-Item $env:LOCALAPPDATA\Microsoft\Windows\Shell\LayoutModification.xml

# Download git repository
git clone https://github.com/jcoconnor/winops2019

# Registry Settings for account
New-ItemProperty -Path 'Registry::HKCU\Control Panel\Desktop' -Name 'LogPixels' -Value 120 -PropertyType DWORD -Force
New-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations' -Name 'IgnoreClientDesktopScaleFactor' -PropertyType DWORD -Value 1 -Force
New-Item -Path 'Registry::HKCU\Software\Microsoft\ServerManager' -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path 'Registry::HKCU\Software\Microsoft\ServerManager' -Name 'DoNotOpenServerManagerAtLogon' -PropertyType DWORD -Value 1 -Force

Get-Process Explorer | Stop-Process


ExitScript 0
