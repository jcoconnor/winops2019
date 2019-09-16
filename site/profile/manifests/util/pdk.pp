# Installs Git for Windows and configures start page.
class profile::util::pdk()
{
  include chocolatey

  package { 'pdk':
    ensure   => installed,
    provider => 'chocolatey',
  }
}
