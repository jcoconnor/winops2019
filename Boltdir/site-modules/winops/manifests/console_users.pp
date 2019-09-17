# Console Users for spinning up a set of admin users
#    azure_client_secret


class winops::console_users (
  String $base_node_name,
  Integer $count = 2,
) {

  range(1,$count).each | $i | {
    $rbac_user_name = sprintf('%s-%02d', $base_node_name, $i)

    rbac_user { $rbac_user_name:
        ensure       => 'present',
        name         => $rbac_user_name,
        display_name => 'Just a testing account',
        email        => 'testing@puppetlabs.com',
        password     => 'WinOps2019',
        roles        => [ 'Operators' ],
    }
  }

}

