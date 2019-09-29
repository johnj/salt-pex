#!/usr/bin/env bash

if [ -e /etc/redhat-release ]; then
  if [ -e /etc/os-release ]; then
    source /etc/os-release
  else
    VERSION_ID=6
  fi

  yum install -y epel-release
  yum groupinstall -y Development Tools
  yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-2018.3-1.el${VERSION_ID}.noarch.rpm
  yum install -y salt-minion

  if [[ $VERSION_ID == "6" ]]; then
    yum install -y libssh2 python-pygit2 mysql-devel gmp-devel python27-devel python27-pip
    pip2.7 install pex
  else
    yum install -y libssh2 python-pygit2 mysql-devel gmp-devel python-devel python-pip dbus-python python-inotify python2-pyroute2 dbus-devel glib2-devel
    pip install pex
  fi
else
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y curl gnupg2 lsb-release
  curl https://repo.saltstack.com/apt/ubuntu/$(lsb_release -rs)/amd64/2018.3/SALTSTACK-GPG-KEY.pub | apt-key add -
  echo "deb http://repo.saltstack.com/apt/ubuntu/$(lsb_release -rs)/amd64/2018.3 $(lsb_release -cs) main" >> /etc/apt/sources.list.d/saltrepo.list
  apt-get update
  apt-get install build-essential python-dev salt-minion salt-master salt-ssh salt-api python-pex-cli libmysqlclient-dev python-configparser python-pip -y
  pip install wheel
fi

pex --python=python2.7 salt mysql-python python-gnupg -c salt-run -o salt-run
pex --python=python2.7 salt mysql-python python-gnupg -c salt-master -o salt-master
pex --python=python2.7 salt mysql-python python-gnupg psutil datetime pyroute2 pyinotify dbus-python ast -c salt-minion -o salt-minion
pex --python=python2.7 salt mysql-python python-gnupg -c salt-api -o salt-api
pex --python=python2.7 salt mysql-python python-gnupg -c salt-call -o salt-call
pex --python=python2.7 salt mysql-python python-gnupg -c salt -o salt
pex --python=python2.7 salt mysql-python python-gnupg -c salt-key -o salt-key
pex --python=python2.7 salt mysql-python python-gnupg -c salt-ssh -o salt-ssh

mkdir /var/tmp/saltbuild
cp /salt-* /var/tmp/saltbuild/
