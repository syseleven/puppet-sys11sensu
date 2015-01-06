class sys11sensu::profile::server::ruby_deps() {
  ensure_packages(['ruby1.9.3', 'ruby1.9.1-dev', 'make'])
}
