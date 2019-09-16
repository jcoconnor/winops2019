# DSC Demo Example to create a user
class profile::dsc::dscusers {
  include profile::dsc::dscbase

  dsc {'dsc_user':
    resource_name => 'User',
    module        => 'PSDesiredStateConfiguration',
    properties    => {
      'username'             => 'winops-dscuser',
      'description'          => 'WinOps 2019 DSC Sample User',
      'ensure'               => 'present',
      'passwordneverexpires' => false,
      'disabled'             => false,
      'password'             => {
        'dsc_type'       => 'MSFT_Credential',
        'dsc_properties' => {
          'user'     => 'jane-doe',
          'password' => Sensitive('StartFooo123&^!')
        }
      },
    }
  }

}
