= Hydradam

== Installation (of VirtualBox VM)

Prerequisites:

  - Oracle VirtualBox
  - Ruby
  - bundler gem

1. Clone the git repository

1. Go to the `deploy` directory

```bash
$ cd ./deploy
```

1. Use bundler to install the deployment Gemfile

```bash
$ bundle install
```

1. Build the Vagrant box and add it to Vagrant:

```bash
$ vagrant basebox build 'centos-62'
$ vagrant basebox export 'centos-62'
$ vagrant box add 'hydradam' centos-62.box
```

1. Start and provision the VM:

```bash
$ vagrant up
```

1. Load the Vagrant ssh config into your `.ssh/config` (setting up a host name alias and private key config):

```bash
$ vagrant ssh-config >> ~/.ssh/config

```

1. Deploy the Rails application

```bash
$ cap deploy && cap deploy:migrate
```

1. ???

1. Open [http://33.33.33.10] in your browser.


