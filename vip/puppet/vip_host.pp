#!/usr/bin/env puppet apply

# Use this to prepare a machine for hosting development environments
# in virtual machines Ubuntu 11.04.

$shared_dir = "/home/$user/projects"

class nfs4_server {
  package { "nfs-kernel-server": ensure => installed }

  service {
    "idmapd":
      require   => Package["nfs-kernel-server"],
      ensure    => running,
      hasstatus => true,
      ;
    "nfs-kernel-server":
      require    => Package["nfs-kernel-server"],
      ensure     => running,
      subscribe  => File["/etc/exports"],
      hasrestart => true,
      hasstatus  => true,
  }

  file {
    "/etc/exports":
      content => "$shared_dir 192.168.122.0/255.255.255.0(rw,sync,no_subtree_check,no_root_squash)\n",
      require => Package["nfs-kernel-server"],
  }
}

class kvm_virtualization {
  package {
    ["virt-manager", "virt-viewer", "ubuntu-virt-server", "python-vm-builder"]:
      ensure => installed,
  }

  exec {
    "/usr/sbin/adduser $user kvm":
      unless  => "/usr/bin/groups $user | grep -q kvm",
      require => Package["ubuntu-virt-server"],
  }

  # Prevent network-manager from removing qemu name server from
  # resolv.conf

  package { ["resolvconf"]: ensure => installed }

  file {
    "/etc/resolvconf/resolv.conf.d/base":
      content => "nameserver 192.168.122.1\n",
      require => Package["resolvconf"],
  }

}

class ssh {
  file {
    "/home/${user}/.ssh/id_virus":
      content => "-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAof+rZVLzoeU7hTCyrqwzLkljnfum9H4z3fCevAPflOdLwD/P
FmRu6wQu9h8KN65r5RM6bhp7KkCFhJdD5qR0RAb2cIYX28lXmidRZgJv1z7vcI2a
S4MbEkOUVovAyquCI+TJk2QeHlLs9P8umrp5Fs4Tqm+BP8M1/PtGrEXOnoKJqvzR
1IuYweuk0uy+hYUeUJHsloeqIDop0j9Qcnp3zDQG7HV8yz7dwRYXrtOQwMCynLWB
ZlH/1v3IPpSzDUKM6bocoUFYAQv26T/mb/HmJ04qGva9g2fwNQict0PE+ykPkfyo
4/YPP3fxpwEklXN9I04WRJdQwRsYxKahNBzr+QIBIwKCAQEAnV7DwYPIGZzau+Yp
64K1YCoI/96E7YHpPf+wJFuIvIjqgD38XuU4jIe4l1FaYfnlJ6xHY6SyKQt6Y4uh
C/A2bfgimTHOCLT2A3am2B+f2GkF2w02zQMEWuKQGY8TDgWxnzYFpR9ttw66TRUl
9WSwJMgwXGxRq6ewyd4nZYWkJPJKiFFpm9SYP5NURA6NSqHbK5z2a2W005PkWPPy
vkT8QecDrAIp8ouLQgvlMw9sVfdQnez+75Nj0IfMf1PJkh/rxmcryrXF4kb99R56
HP77y+1ic/fzzur5v3jl6FJAg1UIu/KYpYhlre1kDNqcXcCjGur2iljX9/oczBUi
eRfXIwKBgQDMlvlpMGb9fGgVsEhJH6cA2JIL32FzNASJdclGc2RZdET5t+omu/JH
CcgG+uxAamdI9cUXMVA6U1a4KNfpfG3QpvWRQglu8wyHwK4TyMTdUkr1b37G5v3I
YN9nJuyDJuYjK7oYqu9Gq1eyb9RCUnT+wo5KQ/FrHpjHPWzX8Zci0wKBgQDKtNzH
OG9n9QJ8J+DF1UaOrPxqk+Mp9EqPpon5hoPPX2MgA3oMwsv/1TLC4TlRwZ6WqgP6
XICih1eBVm4Qp5XCBZaS/3zKhvKW6Hn6mGLJZPhAQyXlCyz5jw6jP03hTREJDjI+
YXLYYRVJKfF9iCGaPYKhCNH4QVsz4lE01O0+gwKBgQCd040z44KmSgcmrI+I3ec7
KrnOpQIIafTfEbiGzguVdvNhjeCER9goLB32wZGuCPCXXoIZNKuatVGGwGwL46Ur
7oLsZiSIyh+b7GkH8qZ+2RVA/j06WmwA+kXwfRzaM/Nc9diz8ZQDUPqCVkSoMPsq
7dt7Hnhok/IzTKRsEiQiLQKBgEtKfeOYnmhw8ktfRNvEPsdHkPRi0LfPw+w2iwTo
0d9PULQejGsjyB0x7khiSH1zzTCljHLvKHbh0At3370LC70YBLpBo2EqzyIb1Yj2
xZtCwpuGp6zYQ+eqKgIe08i2OYcFRdyn2jMcvsNnWbJIgYJunjvQE3l3XGO6de8N
Qi0pAoGBAIL3qqgHBSxBUCASC7SsCXL9NB1OUvHQcPPmSz9MbYHr0gR3niMHI2yW
1otwUfCIeHuFT7YVvozp28G4USJrIZnYLBI2IHosopQo6+ml/kHdIloA7v5Tc9pO
FuMtS0pECA5vw23WysArEzZAwG+2osQMavwJjeLaeVzR8n5nbaOS
-----END RSA PRIVATE KEY-----",
  }

  file {
    "/home/${user}/.ssh/id_virus.pub":
      content => "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAof+rZVLzoeU7hTCyrqwzLkljnfum9H4z3fCevAPflOdLwD/PFmRu6wQu9h8KN65r5RM6bhp7KkCFhJdD5qR0RAb2cIYX28lXmidRZgJv1z7vcI2aS4MbEkOUVovAyquCI+TJk2QeHlLs9P8umrp5Fs4Tqm+BP8M1/PtGrEXOnoKJqvzR1IuYweuk0uy+hYUeUJHsloeqIDop0j9Qcnp3zDQG7HV8yz7dwRYXrtOQwMCynLWBZlH/1v3IPpSzDUKM6bocoUFYAQv26T/mb/HmJ04qGva9g2fwNQict0PE+ykPkfyo4/YPP3fxpwEklXN9I04WRJdQwRsYxKahNBzr+Q== virus",
  }
}

include nfs4_server, kvm_virtualization, ssh

