#!/bin/sh

# /etc/rc.local

######################################################################
# DHCP configuration might not be finished yet when /etc/rc.local is
# run.
#
tries=0

test() {
    ping -c 1 www.google.com > /dev/null
    es=$?
    tries=`expr $tries + 1`
    if [ "$es" -eq 0 ]
    then
        echo Network connection now initialised
        sleep 2
    elif [ $tries -gt 15 ]
    then
        echo Giving up
        exit 1
    else
        echo Waiting for network
        sleep 1
        test # rinse and repeat
    fi
}

test
#
######################################################################

cd /root
curl -L https://github.com/kjellm/vip/tarball/master | tar xz
mv kjellm-vip*/puppet/vip_guest /etc/puppet/modules
curl http://192.168.122.1:8000/site.pp -o site.pp
FACTER_USER=`getent passwd 1000 | cut -d: -f1` puppet apply site.pp

# Replace this script with original (/etc/rc.local)
cp $0~ $0

exit 0
