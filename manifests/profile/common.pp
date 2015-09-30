class sys11sensu::profile::common(
) {

  # needed for sensu-plugin
  package {'ruby-dev':
    ensure => latest,
    before => Package['sensu-plugin'],
  }

  file { '/etc/init.d/sensu-service':
    ensure => file,
    mode   => '0555',
    before => Service['sensu-client'],
    source => "puppet:///modules/$module_name/init_d_sensu-service",
  }
}
