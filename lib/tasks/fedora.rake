require "active-fedora"
require "solrizer-fedora"
require "active_support" # This is just to load ActiveSupport::CoreExtensions::String::Inflections

namespace :fedora do
  desc "Load the object located at the provided path or identified by pid."
  override_task :load => :environment do
    ### override the AF provided task to use the correct fixture directory
    if ENV["pid"].nil? 
      raise "You must specify a valid pid.  Example: rake fedora:load pid=demo:12"
    end
puts "loading #{ENV['pid']}" 
      
    begin
      ActiveFedora::FixtureLoader.new(ENV['dir'] || 'fixtures').reload(ENV["pid"])
    rescue Errno::ECONNREFUSED => e
      puts "Can't connect to Fedora! Are you sure jetty is running?"
    rescue Exception => e
      logger.error("Received a Fedora error while loading #{ENV['pid']}\n#{e}")
    end
  end
end

