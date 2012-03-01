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
