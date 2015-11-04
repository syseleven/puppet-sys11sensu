# sys11sensu

Sys11wrapper for Sensu monitoring

## Example usage

    classes:
      - sys11sensu::role::server
      - sys11monitoring::profile::generic_host
      - exim
     
    repodeploy::repos:
      '/opt/puppet-modules/sys11monitoring':
        source: git@gitlab.syseleven.de:openstack/puppet-sys11monitoring.git
        provider: git
      '/opt/syseleven-base':
        source: git@gitlab.syseleven.de:puppet-manifests/syseleven-base.git
        include:
          - modules/exim
      '/opt/syseleven-private':
        source: git@gitlab.syseleven.de:puppet-manifests/syseleven-private.git
        include:
          - modules/txt_to_sms

      
    exim::role: admin
    exim::postmaster: tf-platform@syseleven.de
    exim::enable_nagioscheck: false  
    sys11sensu::profile::server::handlers::default_handlers:
      - mailer
    sys11sensu::profile::server::handlers::mailer::settings:
      admin_gui: "http://%{openstack_floating_ip}:3001"
      mail_from: 'alpha-alert@syseleven.de'
      mail_to: 'tf-platform@syseleven.de'
      smtp_port: '25'
      smtp_domain: 'sensu.bka.cloud.syseleven.net'
    sys11monitoring::profile::generic_host::check_reboot_needed: false
    sys11sensu::uchiwa_admins:
      'admin1': 'pw1'
      'admin2': 'pw2'
    sys11sensu::uchiwa_users:
      'user1': 'pw1'

    sys11sensu::profile::server::notifications:
      notifications:
        sms:
          targets:
            - +49151foo
            - sms2
          source: sensu
          # only send SMS between 0900 and 1659
          nine_to_five: true
          # only send events for following states
          notification_states: [0, 2] # OK and CRITICAL
