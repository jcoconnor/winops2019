plan winops::win_node_delete(
  String $base_node_name,
  Optional[Integer] $count = 1,
) {
  apply_prep('localhost')

  [ -4, -3, -2, -1 ].each  | $i | {
    apply ('localhost') {
      class { 'winops::win_node':
        base_node_name    =>  $base_node_name,
        count             => $count,
        absent_or_present => 'absent',
        phase             => $i,
      }
    }
  }

  # Powershell tasks to delete:
  # 1. Blobs
  # 2. The DNS Alias Records

  run_task(
    'winops::win_node_del_blobs',
    'localhost',
    base_node_name =>  $base_node_name,
    count          => $count,
  )
  run_task(
    'winops::win_node_del_dnsrecs',
    'localhost',
    base_node_name =>  $base_node_name,
    count          => $count,
  )
}
