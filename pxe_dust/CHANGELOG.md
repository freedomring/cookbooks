## 1.4.0
* refactor the default recipe to include `installers` and `bootstrap_template` recipes
* `bootstrap_template` recipe generates a local mirror bootstrap template that uses a local install.sh and local full stack installers
* `installers` recipe broken out to download the Chef full stack installers and write out Chef bootstraps.
* require `platform` in the `pxe_dust` data bag

## 1.3.4
* switched to LVM for Ubuntu
* Ruby syntax cleanup per https://github.com/styleguide/ruby
* enforce pxe-booted NIC as eth0 via the pxelinux.cfg.erb, 'IPAPPEND 2' and a udev rule in the chef-bootstrap.sh.erb
* added DEBCONF_DEBUG=5 for ridiculous amounts of debugging with preseed
* foodcritic cleanups

## 1.3.2
* added ability to set the environment for nodes
* support OS installation off of network interface besides eth0

## 1.3.0:
* COOK-1621: support unmanaged preseed files (Craig Tracey)
* support new Omnitruck downloads for the Omnibus installer

## 1.2.6:
* COOK-1502: pxe_dust has some if statements that could that could be reduced (Scott M. Likens)
* Changing the addresses databag items to have the hostname as their value (Austin Page)
* Updating default chef version (Austin Page)
* support multiple items in the run list from the data bag
* switch from eth0 to auto for pxelinux.cfg
* take an optional list of packages to install

## 1.2.4:
* take default run_lists when none-specified
* clean up installer when finished

## 1.2.3:
* added attribute for always pulling latest Chef installer

## 1.2.2:
* COOK-1369 Ubuntu 12.04 Precise Pangolin support

## 1.2.1:
* updated to use apt cookbook using apt-cacher-ng
* make local mirrors of the netboots
* added Debian support

## 1.2.0:
* COOK-999 uses the full stack intaller for bootstrapping nodes.

## 1.1.2:
* Fixes COOK-481, COOK-594
