# Install a set of useful packages for the demo
# All of these packages use the chocolatey provider
# and have no dependencies on any other packge being installed.
#

class profile::util::util
{
  $util_packages = [
    'git',
    'googlechrome',
    'notepadplusplus',
    'pdk',
    '7zip.install',
    'sysinternals',
    'treesizefree',
    'vscode',
    'winscp',
  ]

  include chocolatey

  $util_packages.each |$package| {
    package { $package:
      ensure   =>  installed,
      provider => 'chocolatey',
    }
  }
}
