class hydradam {
  group { 'hydra':
    ensure => present;
    'jetty':
      ensure => present;
  }


  user { 'hydradam':
    ensure  => present,
    shell   => '/bin/bash',
    home    => '/wgbh/http/hydradam',
    groups  => ['hydra','rvm'],
    require => [Group['hydra'],Rvm_gem['ruby-1.9.3-p0/passenger']]
  }

  user { 'jetty':
    ensure  => present,
    shell   => '/sbin/nologin',
    home    => '/wgbh/http/hydradam/hydra-app',
    gid     => 'jetty',
    require => [Group['jetty']]
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
