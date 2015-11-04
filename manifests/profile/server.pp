class sys11sensu::profile::server(
  $rabbitmq_host = hiera('sys11sensu::rabbitmq_host', undef),
  $rabbitmq_user = hiera('sys11sensu::rabbitmq_user', undef),
  $rabbitmq_password = hiera('sys11sensu::rabbitmq_password', undef),
  $rabbitmq_vhost = hiera('sys11sensu::rabbitmq_vhost', undef),
  $uchiwa_port = hiera('sys11sensu::uchiwa_port', 3001),
  $uchiwa_stats = hiera('sys11sensu::uchiwa_stats', 10),
  $uchiwa_refresh = hiera('sys11sensu::uchiwa_refresh', 10000),
  $uchiwa_version = hiera('sys11sensu::uchiwa_version', installed),
  $uchiwa_site_host = hiera('sys11sensu::uchiwa_site_host', '127.0.0.1'),
  $uchiwa_site_port = hiera('sys11sensu::uchiwa_site_port', 4567),
  $uchiwa_site_ssl = hiera('sys11sensu::uchiwa_site_ssl', false),
  $uchiwa_site_path = hiera('sys11sensu::uchiwa_site_path', ''),
  $uchiwa_site_user = hiera('sys11sensu::uchiwa_site_user', ''),
  $uchiwa_site_pass = hiera('sys11sensu::uchiwa_site_pass', ''),
  $uchiwa_site_timeout = hiera('sys11sensu::uchiwa_site_timeout', 5),
  $uchiwa_admins = hiera_hash('sys11sensu::uchiwa_admins', {} ),
  $uchiwa_users = hiera_hash('sys11sensu::uchiwa_users', {} ),
  $stashnotifier_enabled = hiera('sys11sensu::stashnotifier::enabled', false),
  # add new repo, will be upstream soon
  $sensu_repo_source = hiera('sensu::repo_source', 'http://repositories.sensuapp.org/apt/'),
  $sensu_repo_key_source = hiera('sensu::repo_key_source','http://repositories.sensuapp.org/apt/pubkey.gpg'),
  $sensu_repo_key_id = hiera('sensu::repo_key_id','EB9C94BB'),
) {
  include sys11sensu::profile::server::handlers
  include sys11sensu::profile::server::checks
  if $stashnotifier_enabled {
    include sys11sensu::profile::server::stashnotifier
  }
  include sys11sensu::profile::server::cli

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
    rabbitmq_password    => $rabbitmq_password,
    rabbitmq_user        => $rabbitmq_user,
    rabbitmq_vhost       => $rabbitmq_vhost,
    server               => true,
    api                  => true,
    sensu_plugin_version => installed,
    client_address       => $client_address,
    repo_source          => $sensu_repo_source,
    repo_key_id          => $sensu_repo_key_id,
    repo_key_source      => $sensu_repo_key_source,
  }

  #sensu::handler { 'default':
  #  command => 'mail -s \'sensu alert\' ops@foo.com',
  #}

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
