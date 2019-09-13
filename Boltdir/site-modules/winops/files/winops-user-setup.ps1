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

Get-Location

Get-ChildItem ENV:

# Wait until 

# Copy-Item $env:LOCALAPPDATA\Microsoft\Windows\Shell\LayoutModification.xml

# Download git repository
Set-Location "C:\Users\$ENV:USERNAME" 
git clone https://github.com/jcoconnor/winops2019
#code winops2019

choco install --no-progress --force --yes vscode-puppet

# Registry Settings for account
New-ItemProperty -Path 'Registry::HKCU\Control Panel\Desktop' -Name 'LogPixels' -Value 120 -PropertyType DWORD -Force

#Get-Process Explorer | Stop-Process


ExitScript 0
