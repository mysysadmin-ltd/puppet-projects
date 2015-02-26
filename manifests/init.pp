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
  basedir = '/srv/projects'
) inherits ::projects::params {

  file { $basedir:
    ensure => directory,
    mode   => 0775,
    owner  => root,
    group  => root
  }

  $projects = hiera_hash('projects',{})
  create_resources('projects::project', $projects)


}

# == Resource type: project
#
# A top level project type.
define projects::project (
  $apache = {},
  $uid = undef,
  $gid = undef,
  $comment = ""
) {

  # If least one project definition exists for this host, creaste the base structure
  if ($apache != {}) {
    user { $title:
      comment => $comment,
      uid     => $uid,
      gid     => $gid,
      home    => '$basedir/$title'
    }

    group { $title:
      comment => $comment,
      gid     => $gid,
    }

    file { '$basedir/$title':
      ensure => directory
    }
  }

  # Create apache vhosts
  if defined(Class['apache']) {
    create_resources('apache::vhost', $apache)
  }
}

