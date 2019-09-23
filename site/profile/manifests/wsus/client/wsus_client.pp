
  # Obligatory comment
  class profile::wsus::client::wsus_client {

    # Enforce Windows Update to run every Sunday.
    class { 'wsus_client':
            server_url             => 'http://win-wsus-01:8530',
            auto_update_option     => 'Scheduled',
            scheduled_install_day  => 'Sunday',
            scheduled_install_hour => 2,
            enable_status_server   => true,
    }
}
