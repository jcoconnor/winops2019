# DSC Demo to create a file.
class profile::dsc::dscfile {

  include profile::dsc::dscbase

  $test_file_contents = 'This file is installed on Desktop for WinOps 2019 Puppet Demo'

  dsc {'dsc_demo_file':
    resource_name => 'File',
    module        => 'PSDesiredStateConfiguration',
    properties    => {
      ensure          => 'Present',
      destinationpath => 'C:\Users\puppet\Desktop\WinOps2019-Demo.txt',
      type            => 'File',
      attributes      => ['Archive','Readonly'],
      contents        => $test_file_contents,
    }
  }
}


