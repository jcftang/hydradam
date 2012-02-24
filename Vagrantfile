# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
#  config.vm.box = "rhel6"
#  config.vm.box_url = "http://puppetlabs.s3.amazonaws.com/pub/rhel60_64.box"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box = "centos-62"
  #config.vm.box_url = "http://packages.vstone.eu/vagrant-boxes/centos/6/centos-6.2-64bit-puppet-vbox.4.1.8.box"
  #config.vm.box = "lucid32"
  #config.vm.box_url = "http://files.vagrantup.com/lucid32.box"


  # Enable provisioning with chef solo, specifying a cookbooks path (relative
  # to this Vagrantfile), and adding some recipes and/or roles.
 # config.vm.provision :chef_solo do |chef|
 #    chef.cookbooks_path = "cookbooks"
 #    chef.add_recipe("dam")
 # end
  #
  config.vm.network :hostonly, "33.33.33.10"

  config.vm.provision :puppet do |puppet|
    puppet.manifest_file = "dam.pp"
    puppet.manifests_path = 'puppet/manifests'
    puppet.module_path = 'puppet/modules'
  end

  config.vm.customize [
    "modifyvm", :id,
    "--name", "Hydradam VM",
    "--memory", "2048"
  ]
end
