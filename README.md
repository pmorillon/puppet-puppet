Work in progress.

## Puppet bootstrap

### Defaults settings

* PUPPET\_VERSION = 3.2.2
* PROXYFIED = false
* PREVENT\_UPDATE = true

### Usage

    $ curl https://raw.github.com/sbadia/puppet-puppet/master/files/scripts/puppet_install.sh | sudo sh
    $ curl https://raw.github.com/sbadia/puppet-puppet/master/files/scripts/puppet_install.sh | sudo PUPPET_VERSION=2.7.19 sh
    $ curl https://raw.github.com/sbadia/puppet-puppet/master/files/scripts/puppet_install.sh | sudo PROXYFIED=true sh
    $ curl https://raw.github.com/sbadia/puppet-puppet/master/files/scripts/puppet_install.sh | sudo PROXYFIED=true PUPPET_VERSION=2.7.12 PREVENT_UPDATE=no sh

### Tested on

* Debian {squeeze,wheezy}
* Ubuntu 12.10, 12.04 (quantal,precise)
* CentOS 6.3
