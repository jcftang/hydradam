set :application, "hydradam"
set :deploy_to, "/var/www/#{application}"
set :domain, 'vagrant'

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :user, 'vagrant'

set :scm, :git
set :repository, "git://github.com/WGBH/hydradam.git"
set :branch, "master"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1
set :group_writable, true

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"  
require 'bundler/capistrano'
set :rvm_ruby_string, '1.9.3@hydradam'


#set :user, "deployer"
#set :scm_passphrase, "p@ssw0rd"

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true                   # This is where Rails migrations will run
role :jetty, domain

server domain, :app, :web, :db, :fedora

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

#If you are using Passenger mod_rails uncomment this:
namespace :deploy do
desc "Compile asets"
  task :assets do
    run "cd #{release_path}; RAILS_ENV=development bundle exec rake assets:clean assets:precompile"
  end
  
  namespace :permissions do
    task :fix do
      sudo "chown -R hydradam:hydra #{latest_release}"
      sudo "chown -R hydradam:hydra #{deploy_to}/shared"
    end
  end

end

namespace :passenger do
  desc "Restart Application"  
  task :restart do  
    run "touch #{current_path}/tmp/restart.txt"  
  end
end


# Make sure the gemset exists before running deploy:setup
def disable_rvm_shell(&block)
  old_shell = self[:default_shell]
  self[:default_shell] = nil
  yield
  self[:default_shell] = old_shell
end

task :create_gemset do
  disable_rvm_shell { run "rvm use #{rvm_ruby_string} --create" }
end

before "deploy:setup", "create_gemset"
before :deploy, "deploy:setup"
after :deploy,  "deploy:assets", "deploy:permissions:fix","passenger:restart"


