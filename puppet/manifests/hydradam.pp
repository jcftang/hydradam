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
    '/wgbh':
      ensure => directory,
      owner  => 'hydradam',
      group  => 'hydradam';

    '/wgbh/http':
      ensure => directory,
      owner  => 'hydradam',
      group  => 'hydradam';

    '/wgbh/http/hydradam':
      ensure => directory,
      owner  => 'hydradam',
      group  => 'hydradam';

    '/wgbh/http/hydradam/hydra-app':
      ensure  => directory,
      owner   => 'hydradam',
      group   => 'hydradam',
      source  => "/vagrant",
      recurse => true;
    '/wgbh/http/hydradam/hydra-jetty':
      ensure => directory,
      source => '/vagrant/jetty',
      owner  => 'jetty',
      group  => 'jetty';
  }

  exec { 'hydradam_setup':
    command  => 'rvm use 1.9.3@hydra-dam && bundle install',
    user     => 'hydradam',
    provider => 'shell',
    path     => '/usr/local/rvm/gems/ruby-1.9.3-p0@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p0/bin:/usr/local/rvm/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
    cwd      => '/wgbh/http/hydradam/hydra-app',
    require  => [File['/wgbh/http/hydradam/hydra-app'], Rvm_gem['ruby-1.9.3-p0/passenger']]
  }

  exec { 'hydradam_config':
    command => '/bin/true',
    require => Exec['hydradam_setup']
  }

  exec { 'hydradam_demo':
    command => 'rvm use 1.9.3@hydra-dam && rails server',
    user     => 'hydradam',
    provider => 'shell',
    path     => '/usr/local/rvm/gems/ruby-1.9.3-p0@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p0/bin:/usr/local/rvm/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
    cwd      => '/wgbh/http/hydradam/hydra-app',
    require => [Exec['jetty_start'], Exec['hydradam_setup']]
  }

  exec { 'jetty_start':
    command => 'java -jar jetty.sh',
    user    => 'jetty',
    path    => '/usr/bin',
    cwd     => '/wgbh/http/hydradam/hydra-jetty',
    require => [File['/wgbh/http/hydradam/hydra-jetty']]
  }


}
