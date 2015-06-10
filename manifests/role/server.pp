class sys11sensu::role::server() {
  anchor { 'sys11sensu::begin': }
  class {'sys11sensu::profile::common': } ->
  class {'sys11sensu::profile::rabbitmq': } ->
  class {'sys11sensu::profile::redis': } ->
  class {'sys11sensu::profile::server': } ->
  anchor { 'sys11sensu::end': }
}

