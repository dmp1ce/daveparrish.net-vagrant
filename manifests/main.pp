file { '/etc/motd.tail':
  content => "===================================================================
This VM hosts the default haskell-vagrant.local development website.
Designed specifically for quickly developing Haskell based products.

For help with this VM please contact dave@upgradeya.com.
===================================================================
"
}

# make sure the packages are up to date before beginning
exec { "apt-get update":
  command => "/usr/bin/apt-get update",
}

# because puppet command are not run sequentially, ensure that packages are
# up to date before installing before installing packages, services, files, etc.
Exec["apt-get update"] -> Package <| |>

class haskell {
  package { "haskell-platform":
    ensure => latest,
  }

  file { "/home/vagrant/.bash_profile":
    owner   => "vagrant",
    group   => "vagrant",
    mode    => 644,
    replace => true,
    ensure  => present,
    source  => "/vagrant/files/.bash_profile",
  }
}

# Basic Puppet Apache manifest
class apache {
  package { "apache2":
    ensure => latest,
  }

  service { "apache2":
    ensure => running,
    require => [ Package["apache2"], File['/vagrant/log'] ],
  }

  file { "/etc/apache2/sites-available/drupal_archive":
    owner   => "root",
    group   => "root",
    mode    => 644,
    replace => true,
    ensure  => present,
    source  => "/vagrant/files/drupal_archive",
    require => Package["apache2"],
  }

  # Turn on Drupal site
  file { "/etc/apache2/sites-enabled/drupal_archive":
    ensure => link,
    target => "/etc/apache2/sites-available/drupal_archive",
    require => [ Package['apache2'], File['/etc/apache2/sites-available/drupal_archive'] ],
    notify  => Service["apache2"]
  }

  # Make sure the log directory exists
  file { "/vagrant/log":
    ensure => "directory",
    owner => "vagrant",
    group => "vagrant",
    mode   => 644,
  }
}

# TODO: Install Hakyll.
# Right now this is a manual step: cabal install hakyll

include haskell
include apache
