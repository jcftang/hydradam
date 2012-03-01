class railsstack {


  include mysql::server
  include apache
  include sqlite

  package { 'expect':
    ensure => present
  }

  class { 'java':
    distribution => 'java-1.6.0-openjdk',
  }

  include rvm

  rvm_system_ruby {
    'ruby-1.9.3-p125':
      ensure      => 'present',
      default_use => false;
  }

  rvm_gem {
    'ruby-1.9.3-p125@global/bundler':
      require => Rvm_system_ruby['ruby-1.9.3-p125'];
    'ruby-1.9.3-p125@global/rails':
      require => Rvm_system_ruby['ruby-1.9.3-p125'];
    'ruby-1.9.3-p125/puppet':
      require => Rvm_system_ruby['ruby-1.9.3-p125'];
    'ruby-1.9.3-p125/passenger':
      require => Rvm_system_ruby['ruby-1.9.3-p125'];
  }

  class {
    'rvm::passenger::apache':
      ruby_version => 'ruby-1.9.3-p125',
      version      => '3.0.11',
      require      => Rvm_gem['ruby-1.9.3-p125/passenger']
  }

  
}
include railsstack

