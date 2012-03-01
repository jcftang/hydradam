class servicemix {
  define download_file(
        $from="",
        $cwd="") {                                                                                         

    exec { $name:                                                                                                                     
        command  => "curl -o ${cwd}/${name} ${from}",                                                         
        cwd      => $cwd,
        path     => "/sbin:/bin:/usr/sbin:/usr/bin",
        creates  => "${cwd}/${name}",                                                              
    }

    file { "${cwd}/${name}":
      mode    => 644,
      require => Exec["${name}"]
    }

    if $require {
      Exec[$name] {
        require +> $require
      }
    }
  }

  define extract_file(
    $destdir="",
    $creates="",
    $to
  ) {
    exec { $name:
      command => "tar -xvz -C ${destdir} -f ${name}",
      path    => "/usr/bin:/bin",
      creates => "${destdir}/${creates}",                                                              
    }

    file { "${destdir}/${creates}":
      mode    => 775,
      require => Exec["${name}"]
    }

    exec { "/bin/mv ${destdir}/${creates} ${to}":
      require => File["${destdir}/${creates}"],
      creates => "${to}"
    }

    file { "${to}":
      require => Exec["/bin/mv ${destdir}/${creates} ${to}"]
    }

  }

  download_file { "apache-servicemix-fuse.tar.gz":
    from => "http://repo.fusesource.com/nexus/content/repositories/releases/org/apache/servicemix/apache-servicemix/4.4.1-fuse-02-05/apache-servicemix-4.4.1-fuse-02-05.tar.gz",
    cwd  => "/tmp"
  }

  extract_file { "/tmp/apache-servicemix-fuse.tar.gz":
    destdir => "/var/www/hydradam",
    creates => "apache-servicemix-4.4.1-fuse-02-05",
    to      => '/var/www/hydradam/servicemix',
    require => [File["/tmp/apache-servicemix-fuse.tar.gz"], File['/var/www/hydradam']]
  }

  exec { '/bin/chown -R vagrant /var/www/hydradam/servicemix':
    require => File["/var/www/hydradam/servicemix"],
    before  => Exec["start servicemix service"]
  }

  file {
    "/etc/init.d/servicemix":
      mode    => "0755",
      content => '#!/bin/sh 
### BEGIN INIT INFO 
# Provides: servicemix 
# Required-Start:
# Required-Stop:
# Default-Start:  3 4 5 
# Default-Stop:   1 
# Short-Description: Apache ServiceMix ESB 
### END INIT INFO 

# Source function library.
. /etc/init.d/functions

# /etc/init.d/servicemix: start and stop the Apache ServiceMix ESB 
SMX_HOME=/var/www/hydradam/servicemix
SMX_USER=vagrant 

start() {
   echo -n "Starting Apache ServiceMix ESB" 
   /bin/su -p -s /bin/sh $SMX_USER -c $SMX_HOME/bin/start
}

case "$1" in 
    start) 
      start
    ;; 
    stop) 
       echo -n "Stopping Apache ServiceMix ESB"

       $SMX_HOME/bin/stop
        
    ;; 
    restart) 
        $0 stop 
        $0 start 
    ;; 
    *) 
       echo -n  "Usage: /etc/init.d/servicemix {start|stop|restart}" 
       exit 1 
esac 
exit 0

'
  }

  exec { "start servicemix service":
    command => "/usr/bin/sudo /sbin/chkconfig servicemix on; /usr/bin/sudo /sbin/service servicemix start", 
    require => [File['/etc/init.d/servicemix'], File["/var/www/hydradam/servicemix"]]
  }

}

include servicemix
