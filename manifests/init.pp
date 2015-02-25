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
) inherits ::projects::params {

  $projects = hiera_hash('projects',{})
  create_resources('project', $projects)

}

# == Resource type: project
#
# A top level project type.
define project (
  $apache = {}
) {

  # Create apache vhosts
  if defined(Class['apache']) {
    create_resources('apache::vhost', $apache)
  }
}
