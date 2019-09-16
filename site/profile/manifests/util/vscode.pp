# Installs Git for Windows and configures start page.
class profile::util::vscode()
{
  include chocolatey

  package { 'vscode':
    ensure   => installed,
    provider => 'chocolatey',
  }
}
