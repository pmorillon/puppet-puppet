#!/bin/bash
# Descritpion : Bash script to install puppet depending the linux distribution

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

if ! [ -z "$PROXYFIED" ]; then export http_proxy="http://proxy.$(hostname -d):3128"; fi

if ! [ -n "$PUPPET_VERSION" ]; then export PUPPET_VERSION="3.1.0"; fi
if ! [ -n "$PUPPET_DEBIAN_SUFFIX" ]; then export PUPPET_DEBIAN_SUFFIX="-1puppetlabs1"; fi

debian_install() {
  export DEBIAN_FRONTEND=noninteractive
  lsb_release_install
  echo -e "\033[0;32mConfigure puppetlabs repo for APT...\033[0m"
  (cd /tmp &&
  wget -q http://apt.puppetlabs.com/puppetlabs-release-$DISTRIB_CODENAME.deb &&
  dpkg -i puppetlabs-release-$DISTRIB_CODENAME.deb &&
  cd -) > /dev/null 2>&1
  debian_puppet_install
}

centos_install() {
  lsb_release_install
  echo -e "\033[0;32mConfigure puppetlabs repo for YUM...\033[0m"
  MAJOR_VERSION=$(echo $DISTRIB_RELEASE | cut -d"." -f1)
  case $MAJOR_VERSION in
    "5")
      rpm -ivh http://yum.puppetlabs.com/el/5/products/i386/puppetlabs-release-5-6.noarch.rpm > /dev/null 2>&1
      centos_puppet_install;;
    "6")
      rpm -ivh http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-6.noarch.rpm > /dev/null 2>&1
      centos_puppet_install;;
    "*")
      echo -e "\033[0;33mCentos $MAJOR_VERSION no supported...\033[0m" && exit ;;
  esac
}

lsb_release_install() {
  echo -e "\033[0;34mLooking for lsb_release...\033[0m"
  which lsb_release > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    case $DISTRIB_ID in
      "Debian" )
        debian_lsb_release_install;;
      "Ubuntu" )
        debian_lsb_release_install;;
      "CentOS" )
        centos_lsb_release_install;;
    esac
  fi
  DISTRIB_RELEASE=$(lsb_release -s -r)
  DISTRIB_CODENAME=$(lsb_release -s -c)
}

debian_lsb_release_install() {
  echo -e "\033[0;32mInstalling lsb-release via APT..\033[0m"
  apt-get -q -y -o dpkg::options::=--force-confold install lsb-release > /dev/null 2>&1
}

centos_lsb_release_install() {
  echo -e "\033[0;32mInstalling lsb-release via YUM...\033[0m"
  yum install redhat-lsb -y > /dev/null 2>&1
}

centos_puppet_install() {
  echo -e "\033[0;32mInstalling puppet $PUPPET_VERSION via YUM...\033[0m"
  yum install puppet-$PUPPET_VERSION -y > /dev/null 2>&1
}

debian_puppet_install() {
  echo -e "\033[0;34mAPT update...\033[0m"
  apt-get update > /dev/null 2>&1
  echo -e "\033[0;32mInstalling puppet $PUPPET_VERSION$PUPPET_DEBIAN_SUFFIX via APT...\033[0m"
  apt-get -q -y -o dpkg::options::=--force-confold install puppet=$PUPPET_VERSION$PUPPET_DEBIAN_SUFFIX puppet-common=$PUPPET_VERSION$PUPPET_DEBIAN_SUFFIX > /dev/null 2>&1
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
  (gem install --no-ri --no-rdoc --version=$PUPPET_VERSION puppet) > /dev/null 2>&1
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
DISTRIB_ID=$(head -n1 /etc/issue | grep -Eo "(Debian|CentOS|Ubuntu)")

echo -e "\033[0;34m  * Linux distribution : $DISTRIB_ID\033[0m"

case $DISTRIB_ID in
  "Debian" ) debian_install ;;
  "Ubuntu" ) debian_install;;
  "CentOS" ) centos_install ;;
  * ) echo -e "\033[0;33mLinux Distribution $DISTRIB_ID no supported...\033[0m" && exit ;;
esac

