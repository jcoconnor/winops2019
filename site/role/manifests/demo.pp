# Role to demonstrate various windows modules/facilities on puppet.
#
class role::demo {

  # Various DSC Type operations.
  include profile::dsc::dscaddreg
  include profile::dsc::dscfile
  include profile::dsc::dscusers

  # Set some registry entries.
  include profile::registry::regentries

  # Create some demo users.
# include profile::users::demousers

  # Set the power configuration.
  include profile::power::power

  # Install Some standard utilities
  include profile::util::gitforwin
  include profile::util::googlechrome
  include profile::util::notepadplusplus
  include profile::util::pdk
  include profile::util::sevenzip
  include profile::util::sysinternals
  include profile::util::treesizefree
  include profile::util::vscode_puppet
  include profile::util::vscode
  include profile::util::winscp

  # Add WSUS Enforcement - TBD Later as exercise
  #include ::profile::wsus::wsus
}
