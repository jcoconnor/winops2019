# Installs Git for Windows and configures start page.
class profile::util::googlechrome()
{
  include chocolatey

  package { 'googlechrome':
    ensure   => installed,
    provider => 'chocolatey',
  }
}
