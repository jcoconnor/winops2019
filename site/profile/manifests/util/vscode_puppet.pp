# Installs Git for Windows and configures start page.
class profile::util::vscode_puppet()
{
  include chocolatey

  package { 'vscode-puppet':
    ensure   => installed,
    provider => 'chocolatey',
  }
}
