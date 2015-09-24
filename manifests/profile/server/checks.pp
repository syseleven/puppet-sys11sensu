class sys11sensu::profile::server::checks(
  $uchiwa_port = hiera('sys11sensu::uchiwa_port', 3001),
) {
  ensure_packages(['nagios-plugins-basic'])

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
  
}
