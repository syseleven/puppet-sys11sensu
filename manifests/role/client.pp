class sys11sensu::role::client() {
  anchor { 'sys11sensu::begin': }
  class {'sys11sensu::profile::common': }
  class {'sys11sensu::profile::client': }
  anchor { 'sys11sensu::end': }
}

