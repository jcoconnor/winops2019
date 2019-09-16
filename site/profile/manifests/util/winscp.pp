# Installs Git for Windows and configures start page.
class profile::util::winscp()
{
  include chocolatey

  package { 'winscp':
    ensure   => installed,
    provider => 'chocolatey',
  }
}
