class sys11sensu::profile::server::handlers::sms(
  $notifications = hiera('sys11sensu::profile::server::notifications'),
) {
  file {'/etc/sensu/handlers/sms.rb':
    ensure => file,
    source => "puppet:///modules/$module_name/handlers/sms.rb",
  }

  sensu::handler {'sms':
      command => '/etc/sensu/handlers/sms.rb',
      type    => 'pipe',
  }
}

