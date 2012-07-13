#!/bin/bash
# http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/

date > /etc/vagrant_box_build_time

yum -y install gcc make gcc-c++ kernel-devel-`uname -r` zlib-devel openssl-devel readline-devel sqlite-devel perl path readline zlib libyaml-devel libffi-devel automake bison iconv-devel autoconf automake bzip2 git rsync libtool patch

curl https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer | bash -s stable

source /etc/profile.d/rvm.sh

rvm --force reinstall ruby-1.9.3

rvm --default use 1.9.3

gem install --no-ri --no-rdoc puppet facter

groupadd puppet
usermod -a -G rvm -G puppet vagrant

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
#curl -L -o authorized_keys https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
chown -R vagrant /home/vagrant/.ssh

# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
curl -L -o VBoxGuestAdditions_$VBOX_VERSION.iso http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

exit
