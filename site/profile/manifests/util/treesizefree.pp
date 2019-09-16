# Installs Git for Windows and configures start page.
class profile::util::treesizefree()
{
  include chocolatey

  package { 'treesizefree':
    ensure   => installed,
    provider => 'chocolatey',
  }
}
