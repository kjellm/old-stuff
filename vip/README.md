VIP
===

VIrtual machine Provisioning for developers.

Use these files to set up development environments using virtual
machines.

This system uses:

- KVM/QEMU/libvirt for virtualization
- Unattended install: Preseeding (Debian/Ubuntu), kickstart (RedHat/CentOS/Fedora/Suse)
- Puppet
- NFSv4 for sharing folders


Usage
-----

### Host

Install dependencies:

    sudo aptitude install puppet-common curl

Ubuntu ships with a puppet configuration that contains references to
etckeeper stuff, making the _puppet apply_ command fail when etckeeper
is not installed. So, comment out those lines:

    sudo perl -pi -e 's/(^(pre|post)run.*)/#$1/' /etc/puppet/puppet.conf

Prepare your physical machine to host virtual machines:

    curl https://raw.github.com/kjellm/vip/master/puppet/vip_host.pp | sudo bash -c 'FACTER_USER=$SUDO_USER puppet apply'

### Creating a virtual machine

FIX
