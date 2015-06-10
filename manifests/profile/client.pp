class sys11sensu::profile::client(
  $rabbitmq_host = hiera('sys11sensu::rabbitmq_host', undef),
  $rabbitmq_user = hiera('sys11sensu::rabbitmq_user', undef),
  $rabbitmq_password = hiera('sys11sensu::rabbitmq_password', undef),
  $rabbitmq_vhost = hiera('sys11sensu::rabbitmq_vhost', undef),
  $safe_mode = hiera('sys11sensu::client::safe_mode', false),
) {

  package {'nagios-plugins-basic':
    ensure => latest,
  }

  vcsrepo { '/opt/sensu-community-plugins':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/sensu/sensu-community-plugins.git',
  }

  if $::is_virtual == 'true' and $::openstack_floating_ip {
    $client_address = $::openstack_floating_ip
  } else {
    $client_address = $::ipaddress
  }

  class { 'sensu':
    rabbitmq_host        => $rabbitmq_host,
    rabbitmq_user        => $rabbitmq_user,
    rabbitmq_password    => $rabbitmq_password,
    rabbitmq_vhost       => $rabbitmq_vhost,
    #subscriptions       => 'sensu-test',
    safe_mode            => $safe_mode,
    sensu_plugin_version => installed,
    purge_config         => true,
    client_address       => $client_address,
  }

  # currently broken in upstream module, always retriggers the subscription
  #sensu::subscription { 'ntp': }
}
