class dam {
  include railsstack
  include hydradam

  #exec { '/usr/sbin/setenforce 0': }

}

#exec { "rvm use system":
#  before => Class['dam']
#}

include dam


class xyz {
  stage { 'top': before => Stage['rvm-install'] }

  class asdfg {
  exec { '/sbin/chkconfig iptables off; /sbin/service iptables stop':
  }

  exec { '/bin/ping rubygems.org -c 5':
    require => Exec['/sbin/chkconfig iptables off; /sbin/service iptables stop']
  }
  }

  class { 'asdfg': stage => 'top' }
}

include xyz

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
    $user="",
    $to
  ) {
    exec { $name:
      command => "tar -xvz -C ${destdir} -f ${name}",
      path    => "/usr/bin:/bin",
      user    => "${user}",
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
