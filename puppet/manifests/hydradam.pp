class hydradam {
  group { 'hydra':
    ensure => present;
    'jetty':
      ensure => present;
  }


  user { 'hydradam':
    ensure  => present,
    shell   => '/bin/bash',
    home    => '/var/www/hydradam',
    groups  => ['hydra','rvm'],
    require => [Group['hydra']]
  }

  user { 'vagrant':
    ensure  => present,
    require => [Group['hydra']]
  }

  User['vagrant']  { groups  +> ["hydra", "rvm"] }

rvm_gemset {
  "ruby-1.9.3-p0@hydradam":
    ensure => present,
    require => Rvm_system_ruby['ruby-1.9.3-p0'];
}
  


  user { 'jetty':
    ensure  => present,
    shell   => '/sbin/nologin',
    home    => '/wgbh/http/hydradam/hydra-app',
    gid     => 'jetty',
    require => [Group['jetty']]
  }

  file { "/var/www/hydradam":
    ensure  => directory,
    group   => 'hydra',
    owner    => 'hydradam',
    mode    => 775,
    require => [User['hydradam'], Class['apache']];

    "/var/www/hydradam/shared":
      ensure  => directory,
      group   => 'hydra',
      owner   => 'hydradam',
      mode    => 775,
      require => File["/var/www/hydradam"];

    "/var/www/hydradam/releases":
      ensure  => directory,
      group   => 'hydra',
      owner   => 'hydradam',
      mode    => 775,
      require => File["/var/www/hydradam"];
  }

  exec { '/usr/sbin/setenforce 0':

  }

  file {
    "/etc/init.d/jetty.sh":
      mode    => "0755",
      content => template("jetty/jetty.erb")
  }

  apache::vhost { 'hydradam':
    port    => '80',
    docroot => '/var/www/hydradam/current/public'
  }

  file { "/etc/default":
      ensure => directory;

    "/etc/default/jetty":
      require  => [User['jetty'],File['/etc/default']],
      content => "JETTY_HOME=/wgbh/http/hydradam/hydra-jetty\nJETTY_USER=jetty"
  }

}
