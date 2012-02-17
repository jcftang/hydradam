class dam {
  include railsstack
  include hydradam
}

#exec { "rvm use system":
#  before => Class['dam']
#}

include dam
