# Add Demo Users using Standard Puppet class
class profile::users::demousers {
  user { 'winopsdemo_1':
    # on Windows can use username, domain\user and SID
    ensure     => present,
    name       => 'WinOps DemoUser 1',
    managehome => true,
    password   => 'GarbledPasswd!',
    groups     => ['Administrators', 'Users']
  }

  user { 'winopsdemo_2':
    # on Windows can use username, domain\user and SID
    ensure     => present,
    name       => 'WinOps DemoUser 2',
    managehome => true,
    password   => 'GarbledPasswd!',
    groups     => ['Administrators', 'Users']
  }
}
