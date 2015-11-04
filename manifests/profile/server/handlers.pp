class sys11sensu::profile::server::handlers(
  $default_handlers = [],
  $notifications = hiera('sys11sensu::profile::server::notifications', undef),
) {

  define load_handler() {
    class { $name: }
  }

  file { '/etc/sensu/handlers/sys11.rb':
    ensure => file,
    mode   => '0444',
    source => "puppet:///modules/$module_name/handlers/sys11.rb",
  }

  if $notifications {
    file {'/etc/sensu/conf.d/handlers/notifications.json':
      ensure  => file,
      mode    => '0444',
      content => template("$module_name/handlers/notifications.json.erb"),
    }
  }

  if $default_handlers {
    require sys11sensu::profile::server::sensu_plugin_gem
    sensu::handler {'default':
      command  => true,
      type     => 'set',
      handlers => $default_handlers
    }

    load_handler { $default_handlers: }
  }
}
