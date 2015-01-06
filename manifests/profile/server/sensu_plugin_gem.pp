class sys11sensu::profile::server::sensu_plugin_gem() {
  require sys11sensu::profile::server::ruby_deps
  exec {'sensu-plugin-gem':
    command     => 'gem1.9.3 install sensu-plugin --no-rdoc --no-ri',
    unless      => 'gem1.9.3 list sensu-plugin | grep sensu-plugin',
    path        => '/bin:/usr/bin',
  } 
}
