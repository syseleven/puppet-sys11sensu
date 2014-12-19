class sys11sensu::profile::server::handlers_dep() {
  ensure_packages(['ruby1.9.3', 'ruby1.9.1-dev', 'make'])
  exec {'sensu-plugin-gem':
    command     => 'gem1.9.3 install sensu-plugin --no-rdoc --no-ri',
    unless      => 'gem1.9.3 list sensu-plugin | grep sensu-plugin',
    path        => '/bin:/usr/bin',
  } 
}
