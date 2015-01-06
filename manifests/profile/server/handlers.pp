class sys11sensu::profile::server::handlers(
  $default_handlers = []
) {

  define load_handler() {
    class { "$name": }
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
