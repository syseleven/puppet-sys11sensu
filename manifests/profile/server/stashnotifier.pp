#
class sys11sensu::profile::server::stashnotifier(
  $from_addr = hiera('sys11sensu::stashnotifier::from'),
  $to_addr = hiera('sys11sensu::stashnotifier::to'),
  $uchiwa_url = hiera('sys11sensu::stashnotifier::uchiwa_url', undef),
  $redis_host = hiera('sys11sensu::stashnotifier::redis_host', 'localhost'),
  $redis_port = hiera('sys11sensu::stashnotifier::redis_port', '6379'),
  $notifier = hiera('sys11sensu::stashnotifier::notifier', 'mailnotifier'),
) {
  file { '/etc/sensu/stash_notifier.cfg':
    ensure  => file,
    mode    => '0444',
    owner   => root,
    group   => root,
    content => template("$module_name/stash_notifier.cfg.erb"),
    notify  => Service['stashnotifier'],
  }

  file { '/etc/sensu/stash_notifier_logging.cfg':
    ensure => file,
    mode   => '0444',
    owner  => root,
    group  => root,
    source => "puppet:///modules/$module_name/stash_notifier_logging.cfg",
    notify => Service['stashnotifier'],
  }

  include apt

  apt::ppa { 'ppa:syseleven-platform/sensu':
  }

  package { 'python-sys11.sensu.stash':
    ensure  => latest,
    require => Apt::Ppa['ppa:syseleven-platform/sensu'],
  }

  service { 'stashnotifier':
    ensure  => running,
    enable  => true,
    require => Package['python-sys11.sensu.stash'],
  }

  file_line { 'redis keyspace events':
    path   => '/etc/redis/redis.conf',
    line   => 'notify-keyspace-events KAE',
    notify => Service['redis-server'],
  }
}
