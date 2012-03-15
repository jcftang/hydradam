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
set   :use_sudo,            false

directory_configuration = %w(db config system)
symlink_configuration = [
  %w(config/database.yml    config/database.yml),
  %w(config/fedora.yml    config/fedora.yml),
  %w(config/solr.yml    config/solr.yml),
  %w(db/production.sqlite3  db/production.sqlite3),
  %w(system                 public/system),
  %w(jetty                 jetty)
]

# Application Specific Tasks
#   that should be performed at the end of each deployment
def application_specific_tasks
  # system 'cap deploy:whenever:update_crontab'
  # system 'cap deploy:delayed_job:stop'
  # system 'cap deploy:delayed_job:start n=1'
  # system 'cap deploy:run_command command="ls -la"'
end


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
  desc "Initializes a bunch of tasks in order after the last deployment process."
  task :restart do
    puts "\n\n=== Running Custom Processes! ===\n\n"
    create_production_log
    setup_symlinks
    application_specific_tasks    
    set_permissions
    system 'cap deploy:passenger:restart'
  end


  desc "Executes the initial procedures for deploying a Ruby on Rails Application."
  task :initial do
    system "cap deploy:setup"
    system "cap deploy"
    system 'cap deploy:apache:restart'
    system "cap deploy:db:create"
    system "cap deploy:db:migrate"
    system "cap deploy:jetty:config"
    system "cap deploy:camel:routes"
    system "cap deploy:fedora:fixtures"
    system "cap deploy:passenger:restart"
  end

  desc "Creates symbolic links from shared folder"
  task :setup_symlinks do
    puts "\n\n=== Setting up Symbolic Links! ===\n\n"
    symlink_configuration.each do |config|
      run "ln -nfs #{File.join(shared_path, config[0])} #{File.join(current_path, config[1])}"
    end
  end
  
  namespace :apache do
    task :restart do
      run "sudo service httpd restart"
    end
  end

 namespace :passenger do

    desc "Restarts Passenger"
    task :restart do
      puts "\n\n=== Restarting Passenger! ===\n\n"
      run "touch #{current_path}/tmp/restart.txt"
    end

  end

 namespace :fedora do
   task :fixtures do
      run "cd #{current_path};RAILS_ENV=production bundle exec rake fedora:load pid=indexable:sdef"
      run "cd #{current_path};RAILS_ENV=production bundle exec rake fedora:load pid=indexable:generic_file_impl"
   end
 end

  
  desc "Sets permissions for Rails Application"
  task :set_permissions do
    puts "\n\n=== Setting Permissions! ===\n\n"
    run "sudo chown -R vagrant:hydra #{deploy_to}"
  end
  
  desc "Creates the production log if it does not exist"
  task :create_production_log do
    unless File.exist?(File.join(shared_path, 'log', 'production.log'))
      puts "\n\n=== Creating Production Log! ===\n\n"
      run "touch #{File.join(shared_path, 'log', 'production.log')}"
    end
  end

  namespace :config do
    desc "Syncs the database.yml file from the local machine to the remote machine"
    task :sync_yaml do
      puts "\n\n=== Syncing database yaml to the production server! ===\n\n"
      unless File.exist?("../config/database.yml")
        puts "There is no ../config/database.yml.\n "
        exit
      end
      system "rsync -vr --exclude='.DS_Store' ../config/database.yml #{user}@#{application}:#{shared_path}/config/"
      puts "\n\n=== Syncing solr yaml to the production server! ===\n\n"
      unless File.exist?("../config/solr.yml")
        puts "There is no ../config/solr.yml.\n "
        exit
      end
      system "rsync -vr --exclude='.DS_Store' ../config/solr.yml #{user}@#{application}:#{shared_path}/config/"
      puts "\n\n=== Syncing fedora yaml to the production server! ===\n\n"
      unless File.exist?("../config/fedora.yml")
        puts "There is no ../config/fedora.yml.\n "
        exit
      end
      system "rsync -vr --exclude='.DS_Store' ../config/fedora.yml #{user}@#{application}:#{shared_path}/config/"
    end
  end

  namespace :db do
  
    desc "Create Production Database"
    task :create do
      puts "\n\n=== Creating the Production Database! ===\n\n"
      run "cd #{current_path}; rake db:create RAILS_ENV=production"
      system "cap deploy:set_permissions"
    end
  
    desc "Migrate Production Database"
    task :migrate do
      puts "\n\n=== Migrating the Production Database! ===\n\n"
      run "cd #{current_path}; rake db:migrate RAILS_ENV=production"
      system "cap deploy:set_permissions"
    end

    desc "Resets the Production Database"
    task :migrate_reset do
      puts "\n\n=== Resetting the Production Database! ===\n\n"
      run "cd #{current_path}; rake db:migrate:reset RAILS_ENV=production"
    end
    
    desc "Destroys Production Database"
    task :drop do
      puts "\n\n=== Destroying the Production Database! ===\n\n"
      run "cd #{current_path}; rake db:drop RAILS_ENV=production"
      system "cap deploy:set_permissions"
    end

    desc "Moves the SQLite3 Production Database to the shared path"
    task :move_to_shared do
      puts "\n\n=== Moving the SQLite3 Production Database to the shared path! ===\n\n"
      run "mv #{current_path}/db/production.sqlite3 #{shared_path}/db/production.sqlite3"
      system "cap deploy:setup_symlinks"
      system "cap deploy:set_permissions"
    end
  
    desc "Populates the Production Database"
    task :seed do
      puts "\n\n=== Populating the Production Database! ===\n\n"
      run "cd #{current_path}; rake db:seed RAILS_ENV=production"
    end
  
  end


  # Tasks that run after the (cap deploy:setup)
  
  desc "Sets up the shared path"
  task :setup_shared_path do
    puts "\n\n=== Setting up the shared path! ===\n\n"
    directory_configuration.each do |directory|
      run "mkdir -p #{shared_path}/#{directory}"
    end
    system "cap deploy:config:sync_yaml"
  end
  
  
 
  
  
desc "Compile asets"
  task :assets do
    run "cd #{current_path}; RAILS_ENV=production bundle exec rake assets:clean assets:precompile"
  end

  namespace :camel do
    desc "deploy camel routes"
    task :routes do
      run "rsync -avz --delete #{current_path}/camel/deploy/* /var/www/hydradam/servicemix/deploy"
    end
  end

  namespace :jetty do
  desc "add ./jetty symlink "
  task :symlink do
    run "ln -nfs /var/www/hydradam/hydra-jetty #{shared_path}/jetty"
  end

  task :config do
    sudo "/sbin/service jetty stop"
    run "cd #{current_path}; bundle exec rake hydra:jetty:config"
    run <<-EOF
cd #{current_path}/jetty;
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

    sleep 30
  end
  end
  

end

namespace :jetty do
  desc "Restart Application"  
  task :restart do  
    sudo "/sbin/service jetty restart"
    sleep 30
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

after :deploy,  "deploy:assets", "deploy:set_permissions"
after 'deploy:setup', 'deploy:setup_shared_path'


