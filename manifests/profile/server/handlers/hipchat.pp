class sys11sensu::profile::server::handlers::hipchat(
  $settings,
) {
  require sys11sensu::profile::server::handlers_dep

  file {'/etc/sensu/conf.d/handlers/hipchat_settings.json':
    ensure  => file,
    mode    => '0444',
    content => template("$module_name/handlers/hipchat_settings.json.erb"),
  }

  file {'/etc/sensu/handlers/hipchat.rb':
    ensure => file,
    source => "puppet:///modules/$module_name/handlers/hipchat.rb",
  }

  exec {'hipchat-gem':
    command     => 'gem1.9.3 install hipchat --no-rdoc --no-ri',
    unless      => 'gem1.9.3 list hipchat | grep hipchat',
    path        => '/bin:/usr/bin',
  }

  sensu::handler {'hipchat':
    command => '/etc/sensu/handlers/hipchat.rb',
    type    => 'pipe',
  }
}
