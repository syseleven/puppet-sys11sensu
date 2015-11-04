class sys11sensu::profile::client(
  $rabbitmq_host = hiera('sys11sensu::rabbitmq_host', undef),
  $rabbitmq_user = hiera('sys11sensu::rabbitmq_user', undef),
  $rabbitmq_password = hiera('sys11sensu::rabbitmq_password', undef),
  $rabbitmq_vhost = hiera('sys11sensu::rabbitmq_vhost', undef),
  $safe_mode = hiera('sys11sensu::client::safe_mode', false),
  $client_custom = {},
  # add new repo, will be upstream soon
  $sensu_repo_source = hiera('sensu::repo_source', 'http://repositories.sensuapp.org/apt/'),
  $sensu_repo_key_source = hiera('sensu::repo_key_source','http://repositories.sensuapp.org/apt/pubkey.gpg'),
  $sensu_repo_key_id = hiera('sensu::repo_key_id','EB9C94BB'),
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

  $client_custom_real = merge($client_custom,
    { 'nodetype'  => $::nodetype,
      'cloudname' => $::cloudname,
    })

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
    client_custom        => $client_custom_real,
    repo_source          => $sensu_repo_source,
    repo_key_id          => $sensu_repo_key_id,
    repo_key_source      => $sensu_repo_key_source,
  }

  # currently broken in upstream module, always retriggers the subscription
  #sensu::subscription { 'ntp': }
}
