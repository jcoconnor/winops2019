# Common base class for DSC to ensure resources are loaded.


class profile::dsc::dscbase {
    Dscfix::Lcm_config { 'disableLCM':
    refresh_mode => 'Disabled'
  }

  # Package installer - using:  hbuckle/powershellmodule
  pspackageprovider {'Nuget':
    ensure => 'present'
  }

  psrepository { 'PSGallery':
    ensure          => present,
    source_location => 'https://www.powershellgallery.com/api/v2',
  }

  package { 'xPSDesiredStateConfiguration':
    ensure   => latest,
    provider => 'windowspowershell',
    source   => 'PSGallery',
  }

  package { 'PSDscResources':
    ensure   => latest,
    provider => 'windowspowershell',
    source   => 'PSGallery',
  }
}
