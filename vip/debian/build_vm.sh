#!/bin/bash

if [ "$1" = "" ]; then 
    echo "Usage: build_vm.sh <NAME>"
    exit 1
fi

NAME=$1
URL="http://192.168.122.1:8000/preseed.cfg"

if curl --head --silent --fail $URL > /dev/null; then
    :
else
    echo "Need a web server running that serves preseed.cfg"
    echo "Start one with 'python2.7 -m SimpleHTTPServer'"
    exit 1
fi

virt-install --name=$NAME \
  --connect qemu:///system \
  --ram=768 \
  --vcpus=2 \
  --disk path=/home/${USER}/vm/${NAME}.img,size=5 \
  --os-type linux --os-variant=debiansqueeze \
  --graphics vnc --hvm --virt-type kvm \
  --network=bridge:virbr0 \
  --location=http://ftp.debian.org/debian/dists/squeeze/main/installer-amd64/ \
  --extra-args="auto=true hostname=${NAME} domain=localdomain url=${URL}"

