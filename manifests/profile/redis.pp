class sys11sensu::profile::redis() {
  package {'redis-server':
    ensure  => latest,
  }
}
