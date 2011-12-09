# FIX add user to fuse group, make sure that /dev/fuse has right permissions

class vip_guest($vm_user, $host_name) {
  
  class grub {
    augeas {
      "grub":
        changes => 'set /files/etc/default/grub/GRUB_TIMEOUT 0',
        notify  => Exec["update-grub"],
    }

    exec {
      "update-grub":
        command => "/usr/sbin/update-grub",
        refreshonly  => true,
    }
  }

  class ssh {
    package { "openssh-server": ensure => installed }

    service {
      "ssh":
        ensure => running,
        #enable     => true, # FIX failes for some reason ...
        hasstatus  => true,
        hasrestart => true,
        require    => Package["openssh-server"],
    }

    ssh_authorized_key {
      "ssh_key":
        ensure => present,
        key    => "AAAAB3NzaC1yc2EAAAABIwAAAQEAof+rZVLzoeU7hTCyrqwzLkljnfum9H4z3fCevAPflOdLwD/PFmRu6wQu9h8KN65r5RM6bhp7KkCFhJdD5qR0RAb2cIYX28lXmidRZgJv1z7vcI2aS4MbEkOUVovAyquCI+TJk2QeHlLs9P8umrp5Fs4Tqm+BP8M1/PtGrEXOnoKJqvzR1IuYweuk0uy+hYUeUJHsloeqIDop0j9Qcnp3zDQG7HV8yz7dwRYXrtOQwMCynLWBZlH/1v3IPpSzDUKM6bocoUFYAQv26T/mb/HmJ04qGva9g2fwNQict0PE+ykPkfyo4/YPP3fxpwEklXN9I04WRJdQwRsYxKahNBzr+Q==",
        name   => "vm_user_key",
        type   => ssh-rsa,
        user   => $vm_user,
    }
  }

  class sudo_nopass {
    package { "sudo": ensure => installed }
  
    file {
      "/etc/sudoers":
        mode    => 0440,
        owner   => "root",
        group   => "root",
        content => template("vip_guest/sudoers.erb"),
        require => Package["sudo"],
    }
  }
  
  class nfs_client_mount {
  
    package {
      ["nfs-common", "portmap"]:
        ensure => installed,
    }

    #augeas {
    #  "nfs-defaults":
    #    changes => "set /files/default/nfs-common/NEED_IDMAPD yes",
    #    require => Package["nfs-common"],
    #}
 
    service {
      "nfs-common":
        ensure    => running,
        enable    => true,
        hasstatus => false,
        require   => Package["nfs-common"],
    }
    
    service {
      "portmap":
        ensure    => running,
        enable    => true,
        hasstatus => false,
        require   => Package["portmap"],
    }
    
    file {
      "share_dir":
        path   => "/home/${vm_user}/share",
        ensure => directory,
        owner  => $vm_user,
        group  => $vm_user,
        ;
    }

    mount {
      "share":
        name    => "/home/${vm_user}/share",
        device  => "192.168.122.1:/home/${vm_user}/projects/",
        require => [ Package["nfs-common"], File["share_dir"] ],
        atboot  => true,
        ensure  => mounted,
        fstype  => "nfs4",
        options => "rw,hard,intr",
        dump    => "0",
        pass    => "0",
        notify  => Service["nfs-common"],
    }

    file {
      "project_dir":
        path   => "/home/${vm_user}/project/",
        ensure => directory,
        owner  => $vm_user,
        group  => $vm_user,
        ;
      "/home/${vm_user}/project/src":
        ensure  => link,
        target  => "/home/${vm_user}/share/${host_name}",
        require => Package["nfs-common", "portmap"],
        owner  => $vm_user,
        group  => $vm_user,
        ;
      "/home/${vm_user}/project/data":
        ensure  => link,
        target  => "/home/${vm_user}/share/data/${host_name}",
        require => Package["nfs-common", "portmap"],
        owner  => $vm_user,
        group  => $vm_user,
        ;
    }
  }
  
  class screen {
  
    package { "byobu": ensure => installed }

    # FIX doesn't work. Prevents ~/.profile from being read
    #file {
    #  "/etc/profile.d/Z98-byobu.sh":
    #    ensure => link,
    #    target => "/usr/bin/byobu-launch",
    #}
  }

  class networking {
    exec {
      "dhcp_send_host_name":
        command => "/usr/bin/perl -pi -e 's/#?\s*(send host-name).*/\$1 \"$host_name\";/' /etc/dhcp/dhclient.conf",
        unless  => "/bin/grep -qx '^send host-name \"$host_name\";' '/etc/dhcp/dhclient.conf'",
    }

    host {
      "vm-host":
        ensure => present,
        ip     => "192.168.122.1",
    }
  }

  class tools {
    package {
      ["vim", "strace", "tree", "curl", "build-essential", "less", "sshfs"]:
        ensure => installed,
    }
  }
  
  include grub, ssh, nfs_client_mount, sudo_nopass, screen, networking, tools
  
}
