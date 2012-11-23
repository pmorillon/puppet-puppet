#!/bin/bash
# Descritpion : Bash script to install puppet depending the linux distribution

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

if ! [ -n "$PUPPET_VERSION" ]; then export PUPPET_VERSION="3.0.0"; fi
if ! [ -n "$PUPPET_DEBIAN_SUFFIX" ]; then export PUPPET_DEBIAN_SUFFIX="-1puppetlabs1"; fi

debian_install() {
  export DEBIAN_FRONTEND=noninteractive

  echo -e "\033[0;32mConfigure puppetlabs repo for APT...\033[0m"
  (cd /tmp &&
  wget -q http://apt.puppetlabs.com/puppetlabs-release-precise.deb &&
  dpkg -i puppetlabs-release-precise.deb &&
  cd -) 2>&1 > /dev/null

  debian_puppet_install
}

centos_install() {
  exit
}

debian_puppet_install() {
  echo -e "\033[0;34mAPT update...\033[0m"
  apt-get update 2>&1 > /dev/null
  echo -e "\033[0;32mInstalling puppet $PUPPET_VERSION$PUPPET_DEBIAN_SUFFIX via apt...\033[0m"
  apt-get -q -y -o dpkg::options::=--force-confold install puppet=$PUPPET_VERSION$PUPPET_DEBIAN_SUFFIX puppet-common=$PUPPET_VERSION$PUPPET_DEBIAN_SUFFIX > /dev/null
  echo -e "\033[0;32mPrevent puppet update by creating a APT preferences file...\033[0m"
  cat << EOF > /etc/apt/preferences.d/puppet.pref
# Prevent puppet upgrades
Package: puppet puppet-common facter hiera
Pin: release main
Pin-Priority: -1
EOF
  if [ $? -eq 0 ]; then
    echo -e "\033[0;32mPuppet $PUPPET_VERSION is now installed.\033[0m"
  fi
}

gem_puppet_install() {
  echo -e "\033[0;32mInstalling Puppet $PUPPET_VERSION...\033[0m"
  (gem install --no-ri --no-rdoc --version=$PUPPET_VERSION puppet) 2>&1 > /dev/null
  if [ $? -eq 0 ]; then
    echo -e "\033[0;32mPuppet $PUPPET_VERSION is now installed.\033[0m"
  fi
}

echo -e "\033[0;34mLooking for a previous puppet installation...\033[0m"
PUPPET_INSTALLED=$(puppet --version 2> /dev/null)
if [ $? -eq 0 ]; then
  echo -e "\033[0;33mPuppet $PUPPET_INSTALLED already installed.\033[0m" && exit
fi

echo -e "\033[0;34mPuppet version to install is $PUPPET_VERSION...\033[0m"

echo -e "\033[0;34mLooking for the current Linux distribution...\033[0m"
DISTRO=$(head -n1 /etc/issue | grep -Eo "(Debian|CentOS)")
MAJOR_VERSION=$(head -n1 /etc/issue | sed -r "s/^.*([1-9]+)\..*$/\1/")
echo -e "\033[0;34m  * Linux distribution : $DISTRO\033[0m"
echo -e "\033[0;34m  * Major version      : $MAJOR_VERSION\033[0m"

case $DISTRO in
  "Debian" ) debian_install ;;
  "Ubuntu" ) debian_install;;
  # "Centos" ) centos_install ;;
  * ) echo -e "\033[0;33mLinux Distro $DISTRO no supported...\033[0m" && exit ;;
esac

