class sys11sensu::profile::server::handlers::stasher() {
  file {'/etc/sensu/handlers/stasher.rb':
    ensure => file,
    source => "puppet:///modules/$module_name/handlers/stasher.rb",
  }

  sensu::handler {'stasher':
      command => '/etc/sensu/handlers/stasher.rb',
      type    => 'pipe',
  }
}

