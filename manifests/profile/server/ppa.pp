#
class sys11sensu::profile::server::ppa(
) {
  include apt

  apt::ppa { 'ppa:syseleven-platform/sensu':
  }
}
