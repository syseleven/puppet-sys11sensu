class sys11sensu::profile::server::handlers(
  $default_handlers = []
) {

  define load_handler() {
    class { "$name": }
  }

  file { '/etc/sensu/handlers/sys11.rb':
    ensure => file,
    mode   => '0444',
    source => "puppet:///modules/$module_name/handlers/sys11.rb",
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
