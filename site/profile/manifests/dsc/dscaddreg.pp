# DSC Demo to create some registry entries.
class profile::dsc::dscaddreg {

  include profile::dsc::dscbase

  dsc { 'dsc_registry_test_binary':
    resource_name => 'Registry',
    module        => 'PSDesiredStateConfiguration',
    properties    => {
      ensure    => 'Present',
      key       => 'HKEY_LOCAL_MACHINE\SOFTWARE\PuppetDSCDemo',
      valuename => 'Dsc_TestBinaryValue',
      valuedata => ['BEEF'],
      valuetype => 'Binary',
    }
  }

  dsc { 'dsc_registry_test_dword':
    resource_name => 'Registry',
    module        => 'PSDesiredStateConfiguration',
    properties    => {
      ensure    => 'Present',
      key       => 'HKEY_LOCAL_MACHINE\SOFTWARE\PuppetDSCDemo',
      valuename => 'Dsc_TestDwordValue',
      valuedata => ['42'],
      valuetype => 'Dword',
    }
  }

  dsc { 'dsc_registry_test_string':
    resource_name => 'Registry',
    module        => 'PSDesiredStateConfiguration',
    properties    => {
      ensure    => 'Present',
      key       => 'HKEY_LOCAL_MACHINE\SOFTWARE\PuppetDSCDemo',
      valuename => 'Dsc_TestStringValue',
      valuedata => ['WinOps 2019 Workshop (DSC)'],
      valuetype => 'String',
    }
  }
}
