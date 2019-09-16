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

  # Install Process Explorer utility.
  include profile::util::sysinternals

  # Add WSUS Enforcement - TBD Later as exercise
  #include ::profile::wsus::wsus
}
