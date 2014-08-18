# copied from nova::rabbitmq
#
class sys11sensu::profile::rabbitmq(
  $userid             = hiera('sys11sensu::rabbitmq_user'),
  $password           = hiera('sys11sensu::rabbitmq_password'),
  $port               ='5672',
  $virtual_host       = hiera('sys11sensu::rabbitmq_vhost'),
  $cluster_disk_nodes = false,
  $enabled            = true,
  $rabbitmq_class     = '::rabbitmq'
) {
  if ($enabled) {
    if $userid == 'guest' {
      $delete_guest_user = false
    } else {
      $delete_guest_user = true
      rabbitmq_user { $userid:
        admin     => true,
        password  => $password,
        provider  => 'rabbitmqctl',
        require   => Class[$rabbitmq_class],
      }
      # I need to figure out the appropriate permissions
      rabbitmq_user_permissions { "${userid}@${virtual_host}":
        configure_permission => '.*',
        write_permission     => '.*',
        read_permission      => '.*',
        provider             => 'rabbitmqctl',
      }->Anchor<| title == 'nova-start' |>
    }
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  if $cluster_disk_nodes {
    class { $rabbitmq_class:
      service_ensure           => $service_ensure,
      port                     => $port,
      delete_guest_user        => $delete_guest_user,
      config_cluster           => true,
      cluster_disk_nodes       => $cluster_disk_nodes,
      wipe_db_on_cookie_change => true,
    }
  } else {
    class { $rabbitmq_class:
      service_ensure    => $service_ensure,
      port              => $port,
      delete_guest_user => $delete_guest_user,
    }
  }

  if ($enabled) {
    rabbitmq_vhost { $virtual_host:
      provider => 'rabbitmqctl',
      require  => Class[$rabbitmq_class],
    }
  }
}
