class sys11sensu::profile::server::handlers() {
  require sys11sensu::profile::server::handlers_dep

  file {'/etc/sensu/conf.d/handlers/hipchat_settings.json':
    ensure  => file,
    mode    => 444,
    content => "
{
  \"hipchat\": {
  \"apikey\": \"4G3ZJ4cBQWOmqJyJUBcI3Ly8mmoxDbGhkmYitZRL\",
  \"apiversion\": \"v2\",
  \"room\": \"sensu-notifications\",
  \"from\": \"Sensu\"
  }
}
",
  }

  file {'/etc/sensu/handlers/hipchat.rb':
    ensure => file,
    source => "puppet:///modules/$module_name/handlers/hipchat.rb",
  } 

  #exec {'change hipchat.rb shebang':
  #  command => '/bin/sed -i \'1 s@^.*$@#!/usr/bin/env ruby1.9.3@\' /etc/sensu/handlers/hipchat.rb',
  #  refreshonly => true,
  #}

  exec {'sensu-plugin-gem':
    command     => 'gem1.9.3 install sensu-plugin --no-rdoc --no-ri',
    unless      => 'gem1.9.3 list sensu-plugin | grep sensu-plugin',
    path        => '/bin:/usr/bin',
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

