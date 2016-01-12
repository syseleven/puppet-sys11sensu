class sys11sensu::profile::server::checks(
  $uchiwa_port = hiera('sys11sensu::uchiwa_port', 3001),
  $extra = []   # Additional checks to run from this server. Takes a hash of check names
                # with parameter hashes for values.
) {
  ensure_packages(['nagios-plugins-basic'])

  if ! empty($extra) {
    $checknames = keys($extra)

    extras{$checknames:
      params => $extra
    }
  }

  sensu::check { 'sensu-dashboard-http':
    command => "PATH=\$PATH:/usr/lib/nagios/plugins check_http -H localhost -p $uchiwa_port",
  }

  sensu::check { 'sensu-api':
    command     => 'PATH=$PATH:/usr/lib/nagios/plugins check_http -H localhost -p 4567 -e 404',
  }

  sensu::check { 'sensu-rabbitmq':
    command => '/usr/lib/nagios/plugins/check_tcp -H localhost -p 5672',
  }

  sensu::check { 'sensu-redis':
    command => '/usr/lib/nagios/plugins/check_tcp -H localhost -p 6379',
  }

  # Wrapper for processing $checks hash.
  define extras($params){
    notice("creating Sensu::Check[$name]")
    ensure_resource('sensu::check', $name, $params[$name])
  }
}
