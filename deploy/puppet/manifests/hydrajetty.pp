class hydrajetty {

  file {
    "/etc/init.d/jetty":
      mode    => "0755",
      content => template("jetty/jetty.erb"),
      require => Exec['checkout hydra-jetty']
  }

  
  file { "/var/www/hydradam/hydra-jetty/etc/jetty-logging.xml":
    mode    => "0644",
    content => template("jetty/jetty-logging.xml"),
    require => Exec['checkout hydra-jetty']
  }

  
  exec { "checkout hydra-jetty":
    creates => "/var/www/hydradam/hydra-jetty",
    command => "git clone git://github.com/projecthydra/hydra-jetty.git",
    cwd     => "/var/www/hydradam",
    path    => "/usr/bin:/bin",
    user    => 'vagrant',
    require => File['/var/www/hydradam']
  }


   download_file { "mysql-connector-java.tar.gz":
    from => "http://mirror.services.wisc.edu/mysql/Downloads/Connector-J/mysql-connector-java-5.1.18.tar.gz",
    cwd  => "/tmp"
  }

  extract_file { "/tmp/mysql-connector-java.tar.gz":
    destdir => "/tmp/",
    creates => "mysql-connector-java-5.1.18",
    to      => '/tmp/mysql-connector-java',
    require => [File["/tmp/mysql-connector-java.tar.gz"]]
  }

  exec { "cp /tmp/mysql-connector-java/mysql-connector-java-5.1.18-bin.jar /var/www/hydradam/hydra-jetty/webapps/fedora/WEB-INF/lib":
     creates => '/var/www/hydradam/hydra-jetty/webapps/fedora/WEB-INF/lib/mysql-connector-java-5.1.18-bin.jar',
     cwd     => "/var/www/hydradam",
     path    => '/usr/bin:/bin',
     require => [File['/tmp/mysql-connector-java'], Exec['checkout hydra-jetty']]
  }
  

  exec { 'start jetty service':
    command => "/usr/bin/sudo /sbin/chkconfig jetty on; /usr/bin/sudo /sbin/service jetty start", 
    require => [File['/etc/init.d/jetty'], File["/etc/default/jetty"]]
  }

    file { "/etc/default":
      ensure => directory;

    "/etc/default/jetty":
      require  => [File['/etc/default']],
      content => "JETTY_HOME=/var/www/hydradam/hydra-jetty\nJETTY_USER=vagrant"
  }

}
