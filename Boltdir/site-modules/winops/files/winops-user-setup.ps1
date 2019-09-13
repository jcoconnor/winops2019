# Script to initialise winops user account
#

# 1. Download git repository
git clone https://github.com/jcoconnor/winops2019

# 2. Setup Shortcuts

# 3. Initialise vscode extension for puppet


# 4. Registry Settings for account
New-ItemProperty -Path 'Registry::HKCU\Control Panel\Desktop' -Name 'LogPixels' -Value 120 -PropertyType DWORD -Force
New-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations' -Name 'IgnoreClientDesktopScaleFactor' -PropertyType DWORD -Value 1 -Force
New-Item -Path 'Registry::HKCU\Software\Microsoft\ServerManager' -Force
New-ItemProperty -Path 'Registry::HKCU\Software\Microsoft\ServerManager' -Name 'DoNotOpenServerManagerAtLogon' -PropertyType DWORD -Value 1 -Force

