class sys11sensu::profile::server::handlers(
  $hipchat_settings = false,
) {
  require sys11sensu::profile::server::handlers_dep

  if $hipchat_settings {
    file {'/etc/sensu/conf.d/handlers/hipchat_settings.json':
      ensure  => file,
      mode    => '0444',
      content => template("$module_name/hipchat_settings.json.erb"),
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

    sensu::handler {'default':
      command => '/etc/sensu/handlers/hipchat.rb',
      type    => 'pipe',
    }
  }

  exec {'sensu-plugin-gem':
    command     => 'gem1.9.3 install sensu-plugin --no-rdoc --no-ri',
    unless      => 'gem1.9.3 list sensu-plugin | grep sensu-plugin',
    path        => '/bin:/usr/bin',
  }

}

