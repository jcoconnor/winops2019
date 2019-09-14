plan winops::win_node_delete(
  String $base_node_name,
  Optional[Integer] $count = 1,
) {
  apply_prep('localhost')
  apply ('localhost') {
    class { 'winops::win_node':
      base_node_name    =>  $base_node_name,
      count             => $count,
      absent_or_present => 'absent',
      phase             => 3,
    }
  }

  # Powershell tasks to delete:
  # 1. Blobs
  # 2. The DNS Alias Records
}
