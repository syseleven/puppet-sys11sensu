#
class sys11sensu::profile::server::cli() {

  include sys11sensu::profile::server::ppa

  package { 'ruby-sensu-cli':
    ensure  => latest,
    require => Apt::Ppa['ppa:syseleven-platform/sensu'],
  }

}
