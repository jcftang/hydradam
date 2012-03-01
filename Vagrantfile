# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |global_config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  global_config.vm.define(ENV['name'] || :hydradam) do |config|
    # Every Vagrant virtual environment requires a box to build off of.
    config.vm.box = ENV['box'] || "hydradam"

    config.vm.network :hostonly, "33.33.33.10"

    config.vm.provision :puppet do |puppet|
      puppet.manifest_file = "dam.pp"
      puppet.manifests_path = 'puppet/manifests'
      puppet.module_path = 'puppet/modules'
    end

    config.vm.customize [
      "modifyvm", :id,
      "--name", "Hydradam VM",
      "--memory", (ENV['mem'] || "2048")
    ]
  end
end
