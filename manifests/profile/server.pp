class sys11sensu::profile::server(
  $rabbitmq_host = hiera('sys11sensu::rabbitmq_host', undef),
  $rabbitmq_user = hiera('sys11sensu::rabbitmq_user', undef),
  $rabbitmq_password = hiera('sys11sensu::rabbitmq_password', undef),
  $rabbitmq_vhost = hiera('sys11sensu::rabbitmq_vhost', undef),
  $uchiwa_port = hiera('sys11sensu::uchiwa_port', 3001),
  $uchiwa_version = hiera('sys11sensu::uchiwa_version', installed),
) {
  include sys11sensu::profile::server::handlers
  include sys11sensu::profile::server::checks

  vcsrepo { "/opt/sensu-community-plugins":
    ensure   => present,
    provider => git,
    source   => 'https://github.com/sensu/sensu-community-plugins.git',
  }

  if $::is_virtual == 'true' and $::openstack_floating_ip {
    $client_address = $::openstack_floating_ip
  } else {
    $client_address = $::ipaddress
  }

  if $::openstack_stack_name {
    $site_name = $::openstack_stack_name
  } else {
    $site_name = 'localhost'
  }


  class { '::sensu':
    rabbitmq_password => $rabbitmq_password,
    rabbitmq_user     => $rabbitmq_user,
    rabbitmq_vhost    => $rabbitmq_vhost,
    server            => true,
    api               => true,
    sensu_plugin_version => installed,
    client_address       => $client_address,
    #safe_mode        => false,
    #plugins          => [
    #  'puppet:///data/sensu/plugins/ntp.rb',
    #  'puppet:///data/sensu/plugins/postfix.rb'
    #]
  }

  #sensu::handler { 'default':
  #  command => 'mail -s \'sensu alert\' ops@foo.com',
  #}

  # there is no purge on type sensu_check
  sensu::check { 'check_ntp':
    ensure  => absent,
    command => '/dev/null',
  }

  sensu::check { 'ntp':
    command     => 'PATH=$PATH:/usr/lib/nagios/plugins check_ntp_time -H pool.ntp.org -w 30 -c 60',
    #handlers   => 'default',
    subscribers => 'ntp',
    standalone  => false,
  }

  # dashboard
  #http://sensuapp.org/docs/latest/dashboards_uchiwa
  package {'uchiwa':
    ensure => $uchiwa_version,
  }


  if versioncmp($uchiwa_version, '0.3.0') > 0 {
    file {'uchiwa.config':
      ensure  => file,
      path    => '/etc/sensu/uchiwa.json',
      mode    => '0444',
      content => template("$module_name/uchiwa.json.0.3.erb"),
      notify  => Service['uchiwa'],
    }
  } elsif versioncmp($uchiwa_version, '0.2.0') > 0 {
    # new .json for > 0.2
    file {'uchiwa.config':
      ensure  => file,
      path    => '/etc/sensu/uchiwa.json',
      mode    => '0444',
      content => template("$module_name/uchiwa.json.erb"),
      notify  => Service['uchiwa'],
    }
  } else {
    file {'uchiwa.config':
      ensure  => file,
      path    => '/etc/sensu/uchiwa.js',
      mode    => '0444',
      content => template("$module_name/uchiwa.js.erb"),
      notify  => Service['uchiwa'],
    }
  }

  service {'uchiwa':
    ensure    => running,
    enable    => true,
  }
}
