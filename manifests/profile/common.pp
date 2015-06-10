class sys11sensu::profile::common(
) {

  # needed for sensu-plugin
  package {'ruby-dev':
    ensure => latest,
    before => Package['sensu-plugin'],
  }

}
