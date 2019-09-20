# Simple class to set the wallpaper.
class profile::wallpaper::wallpaper {

  # https://community.spiceworks.com/topic/1988596-powershell-to-change-desktop-image

  $wallpaper_file = 'C:\Users\puppet\Pictures\puppet-heart-1920x1080.png'

  file { $wallpaper_file:
    ensure => file,
    mode   => '0660',
    source => 'puppet:///modules/wallpaper/puppet-heart-1920x1080.png',
  } -> registry::value { 'desktop_wallpaper':
      key   => 'HKEY_CURRENT_USER\Control Panel\Desktop',
      value => 'wallpaper',
      data  => '42',
      type  => 'string'
  } -> exec { 'Refresh Background':
    command     => 'rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True',
    path        => 'C:\Windows\System32;C:\Windows\System32\WindowsPowerShell\v1.0',
    provider    => powershell,
    refreshonly => true,
    logoutput   => true,
  }
}
