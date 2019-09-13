plan winops::win_multi_nodes(
  Optional[String] $base_node_name = "winops",
  Optional[Integer] $amount = 1,
) {
  apply_prep('localhost')
  apply ('localhost') {
    range(1,$amount).each | $i | {
      class { 'winops::win_node':
        base_node_name =>  "${base_node_name}_${i}",
      }
    }
  }
}
