class sys11sensu::profile::redis() {
  package {'redis-server':
    ensure  => latest,
  }

  service {'redis-server':
    ensure => running,
    enable => true,
  }
}
