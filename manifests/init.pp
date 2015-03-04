# == Class: projects
#
# A puppet module to manage top level projects.
#
# === Examples
#
# === Authors
#
# Dan Foster <dan@zem.org.uk>
#
# === Copyright
#
# Copyright 2015 Dan Foster, unless otherwise noted.
#
class projects (
  $basedir = '/srv/projects'
) inherits ::projects::params {

  file { $basedir:
    ensure => directory,
    mode   => 0775,
    owner  => root,
    group  => root
  }

  $projects = hiera_hash('::projects',{})
  create_resources('::projects::project', $projects)


}

# == Resource type: project
#
# A top level project type.
define projects::project (
  $apache = {},
  $uid = undef,
  $gid = undef,
  $users = [],
  $description = ""
) {

  # If least one project definition exists for this host, creaste the base structure
  if ($apache != {}) {
    user { $title:
      comment => $description,
      uid     => $uid,
      gid     => $gid,
      home    => "$::projects::basedir/$title"
    }

    group { $title:
      gid     => $gid,
    }

    file { "$::projects::basedir/$title":
      ensure => directory,
      owner  => $title,
      group  => $title
    }

    file { "$::projects::basedir/$title/var":
      ensure => directory,
      owner  => $title,
      group  => $title
    }

    file { "$::projects::basedir/$title/etc":
      ensure => directory,
      owner  => $title,
      group  => $title
    }
  }

  # Create apache vhosts
  if defined(Class['apache']) {
    projects::project::apache { $name:
      vhosts = $apache
    }
  }
}

# -- Resource type: project::apache
#
# Defines an apache project
define projects::project::apache (
  $vhosts = {}
) {

    file { "$::projects::basedir/$projectnamei/var/www":
      ensure => directory,
      owner  => $title,
      group  => $title
    }

    file { "$::projects::basedir/$projectnamei/etc/apache":
      ensure => directory,
      owner  => $title,
      group  => $title
    }

    each($vhosts) |$k,$v| 
    {
    }
    create_resources('apache::vhost', $vhosts)
}

