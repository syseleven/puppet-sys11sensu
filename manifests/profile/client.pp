class sys11sensu::profile::client(
  $rabbitmq_host = hiera('sys11sensu::rabbitmq_host', undef),
  $rabbitmq_user = hiera('sys11sensu::rabbitmq_user', undef),
  $rabbitmq_password = hiera('sys11sensu::rabbitmq_password', undef),
  $rabbitmq_vhost = hiera('sys11sensu::rabbitmq_vhost', undef),
  $safe_mode = hiera('sys11sensu::client::safe_mode', false),
) {

  # needed for sensu-plugin
  package {'ruby-dev':
    ensure => latest,
  }  

  package {'nagios-plugins-basic':
    ensure => latest,
  }

  vcsrepo { "/opt/sensu-community-plugins":
    ensure   => present,
    provider => git,
    source   => 'https://github.com/sensu/sensu-community-plugins.git',
  }

  class { 'sensu':
    rabbitmq_host        => $rabbitmq_host,
    rabbitmq_user        => $rabbitmq_user,
    rabbitmq_password    => $rabbitmq_password,
    rabbitmq_vhost       => $rabbitmq_vhost,
    #subscriptions       => 'sensu-test',
    safe_mode            => $safe_mode,
    sensu_plugin_version => installed,
  }

  # iso9660 is /config metadata filesystem, it always is 100%
  sensu::check { "diskspace":
    command => '/opt/sensu-community-plugins/plugins/system/check-disk.rb -x iso9660',
  }

  # currently broken in upstream module, always retriggers the subscription
  #sensu::subscription { 'ntp': }
}
