# Simple class to set the wallpaper.
class profile::wallpaper::wallpaper {

  # Get active scheme and return 1 if it doesn't match expected value
  $check = "Registry Setting..."

  # https://community.spiceworks.com/topic/1988596-powershell-to-change-desktop-image
  # Don't need check.

  exec { 'set power scheme':
    command   => 'rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True',
    path      => 'C:\Windows\System32;C:\Windows\System32\WindowsPowerShell\v1.0',
    unless    => $check,
    provider  => powershell,
    logoutput => true,
  }
}


#Function Set-WallPaper($Value)
#{
  #Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value $value
  # rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True
#}

# Set-WallPaper -value "C:\Windows\Web\Wallpaper\Homes_Background.bmp"
