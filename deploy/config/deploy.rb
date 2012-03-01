set :application, "hydradam"
set :deploy_to, "/var/www/#{application}"
set :domain, (ENV['name'] || 'hydradam')

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
    run "cd #{release_path}; RAILS_ENV=production bundle exec rake assets:clean assets:precompile"
  end

  task :chown do
    sudo "chown -R vagrant:hydra /var/www/hydradam"
  end

  namespace :jetty do
  desc "add ./jetty symlink "
  task :symlink do
    run "ln -s /var/www/hydradam/hydra-jetty #{release_path}/jetty"
  end

  task :config do
    sudo "/sbin/service jetty stop"
    run "cd #{release_path}; bundle exec rake hydra:jetty:config"
    run <<-EOF
cd #{release_path}/jetty;
echo 'spawn fedora/default/server/bin/fedora-rebuild.sh

sleep 2
expect ">"
send "1"
send "\r"
sleep 1
expect ">"
sleep 1
send "1"
send "\r"
expect ">"
sleep 1
send "1"
send "\r"
wait

' | FEDORA_HOME=`pwd`/fedora/default CATALINA_HOME=`pwd` expect -f -

EOF
    sudo "/sbin/service jetty start"
  end
  end
  

end

namespace :passenger do
  desc "Restart Application"  
  task :restart do  
    sudo "/sbin/service httpd reload"
    run "touch #{current_path}/tmp/restart.txt"  
  end
end


namespace :jetty do
  desc "Restart Application"  
  task :restart do  
    sudo "/sbin/service jetty restart"
  end
end
namespace :rvm do
  desc 'Trust rvmrc file'
  task :trust_rvmrc do
    run "rvm rvmrc trust #{current_release}"
  end
end

after "deploy:update_code", "rvm:trust_rvmrc"


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

before "deploy:jetty:config", "deploy:jetty:symlink"
after "deploy:jetty:config", "jetty:restart"

after :deploy,  "deploy:assets", "deploy:chown", "deploy:jetty:config", "passenger:restart"
after "deploy:migrate", "passenger:restart"


