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
  "ruby-1.9.3-p125@hydradam":
    ensure => present,
    require => Rvm_system_ruby['ruby-1.9.3-p125'];
}
  


  user { 'jetty':
    ensure  => present,
    shell   => '/bin/bash',
    home    => '/var/www/hydradam/hydra-jetty',
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

  #exec { '/usr/sbin/setenforce 0': }

  exec { '/sbin/chkconfig iptables off; /sbin/service iptables stop':
  }

  file {
    "/etc/init.d/jetty.sh":
      mode    => "0755",
      content => template("jetty/jetty.erb"),
      require => Exec['checkout hydra-jetty']
  }

  file { "/var/www/hydradam/hydra-jetty/etc/jetty-logging.xml":
    mode    => "0644",
    content => template("jetty/jetty-logging.xml"),
    require => Exec['checkout hydra-jetty']
  }

define line($file, $line, $ensure = 'present') {
    case $ensure {
        default : { err ( "unknown ensure value ${ensure}" ) }
        present: {
            exec { "/bin/echo '${line}' >> '${file}'":
                unless => "/bin/grep -qFx '${line}' '${file}'"
            }
        }
        absent: {
            exec { "/bin/grep -vFx '${line}' '${file}' | /usr/bin/tee '${file}' > /dev/null 2>&1":
              onlyif => "/bin/grep -qFx '${line}' '${file}'"
            }

            # Use this resource instead if your platform's grep doesn't support -vFx;
            # note that this command has been known to have problems with lines containing quotes.
            # exec { "/usr/bin/perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
            #     onlyif => "/bin/grep -qFx '${line}' '${file}'"
            # }
        }
    }
}

  exec { "checkout hydra-jetty":
    creates => "/var/www/hydradam/hydra-jetty",
    command => "git clone git://github.com/projecthydra/hydra-jetty.git",
    cwd     => "/var/www/hydradam",
    path    => "/usr/bin:/bin"
  }

  exec { "chown hydra-jetty":
    command => "/bin/chown -R jetty /var/www/hydradam/hydra-jetty",
    require => [Exec['checkout hydra-jetty'], User['jetty']]
  }

  exec { "/usr/bin/sudo /sbin/chkconfig jetty.sh on; /usr/bin/sudo /sbin/service jetty.sh start": 
    require => [File['/etc/init.d/jetty.sh'], Exec['chown hydra-jetty'], File["/etc/default/jetty"]]
  }

  file { "/etc/httpd/conf.d/vhosts":
    before => File["/etc/httpd/conf.d//vhosts/25-hydradam.conf"],
    ensure => directory
  }

  line { "vhosts at end of file":
    file    => "/etc/httpd/conf/httpd.conf",
    line    => "Include conf.d/vhosts/*.conf",
    require => Apache::Vhost['hydradam'],
    notify  => Service['httpd']
  }

  apache::vhost { 'hydradam':
    port     => '80',
    docroot  => '/var/www/hydradam/current/public',
    priority => 'vhosts/25',
  }

  file { "/etc/default":
      ensure => directory;

    "/etc/default/jetty":
      require  => [User['jetty'],File['/etc/default']],
      content => "JETTY_HOME=/var/www/hydradam/hydra-jetty\nJETTY_USER=jetty"
  }

}
