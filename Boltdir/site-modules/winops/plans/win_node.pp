plan winops::win_node(
  String $base_node_name,
) {
  apply ('localhost') {
    class { 'winops::win_node':
      base_node_name =>  $base_node_name,
    }
  }
}
