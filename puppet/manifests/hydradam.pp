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
    require => [User['hydradam']]

  }

  file {
    "/etc/init.d/jetty.sh":
      mode    => "0755",
      content => template("jetty/jetty.erb")
  }

  file { "/etc/default":
      ensure => directory;

    "/etc/default/jetty":
      require  => [User['jetty'],File['/etc/default']],
      content => "JETTY_HOME=/wgbh/http/hydradam/hydra-jetty\nJETTY_USER=jetty"
  }

}
