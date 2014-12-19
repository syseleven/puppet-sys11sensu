class sys11sensu::profile::server::handlers::mailer(
  $settings,
) {
  require sys11sensu::profile::server::handlers_dep

  file {'/etc/sensu/conf.d/handlers/mailer_settings.json':
    ensure  => file,
    mode    => '0444',
    content => template("$module_name/handlers/mailer_settings.json.erb"),
  }

  file {'/etc/sensu/handlers/mailer.rb':
    ensure => file,
    source => "puppet:///modules/$module_name/handlers/mailer.rb",
  } 

  exec {'mailer-gem':
    command     => 'gem1.9.3 install mail --no-rdoc --no-ri',
    unless      => 'gem1.9.3 list mail | grep mail',
    path        => '/bin:/usr/bin',
  }

  sensu::handler {'mailer_handler':
      command => '/etc/sensu/handlers/mailer.rb',
      type    => 'pipe',
  }
}

