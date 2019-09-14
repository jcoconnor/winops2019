plan winops::win_node_create(
  String $base_node_name,
  Optional[Integer] $count = 1,
) {
  apply_prep('localhost')
  apply ('localhost') {
    class { 'winops::win_node':
      base_node_name =>  $base_node_name,
      count          => $count,
      phase          => 1,
    }
  }
  apply ('localhost') {
    class { 'winops::win_node':
      base_node_name =>  $base_node_name,
      count          => $count,
      phase          => 2,
    }
  }
  apply ('localhost') {
    class { 'winops::win_node':
      base_node_name =>  $base_node_name,
      count          => $count,
      phase          => 3,
    }
  }

  run_task(
    'winops::win_node_add_dnsrecs',
    'localhost',
    base_node_name =>  $base_node_name,
    count          => $count,
  )
}
