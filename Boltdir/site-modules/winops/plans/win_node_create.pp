plan winops::win_node_create(
  String $base_node_name,
  Optional[Integer] $count = 1,
) {
  apply_prep('localhost')
  # Apply the win_node class in 3 phases which
  # allows the network elemtents to initialise
  # before the vms.
  # Repeat Phase 3 as the host create sometimes times out.
  #
  [ 1, 2, 3, 3].each | $i | {
    apply ('localhost') {
      class { 'winops::win_node':
        base_node_name =>  $base_node_name,
        count          => $count,
        phase          => $i,
      }
    }
  }

  run_task(
    'winops::win_node_add_dnsrecs',
    'localhost',
    base_node_name =>  $base_node_name,
    count          => $count,
  )
}
