# -- Resource type: project::apache
#
# Defines an apache project
define projects::project::apache (
  $vhosts = {},
  $apache_user = 'apache'
) {

  file { "$::projects::basedir/$title/var/www":
    ensure  => directory,
    owner   => $apache_user,
    group   => $title,
    mode    => 0570,
    seltype => 'httpd_sys_content_t',
    require => File["$::projects::basedir/$title/var"],
  }

  file { "$::projects::basedir/$title/etc/apache":
    ensure  => directory,
    owner   => $title,
    group   => $title,
    require => File["$::projects::basedir/$title/etc"],
  }

  file { "$::projects::basedir/$title/etc/apache/conf.d":
    ensure  => directory,
    owner   => $title,
    group   => $title,
    mode    => 0770,
    require => File["$::projects::basedir/$title/etc/apache"],
  }

  create_resources('::projects::project::apache::vhost', $vhosts, {
    'projectname' => $title,
  })
  create_resources('::apache::vhost', $vhosts, {
    'docroot'     => "$::projects::basedir/$title/var/www",
  })

}

# -- Resource type: project::apache::vhost
#
# Configures and projec apache vhost.
define projects::project::apache::vhost (
  $projectname = undef,
  $docroot = undef,
  $port = undef,
  $vhost_name = undef,
  $ssl = false
) {

  file { "$::projects::basedir/$projectname/etc/apache/conf.d/$title":
    ensure  => directory,
    owner   => $projectname,
    group   => $projectname,
    require => File["$::projects::basedir/$projectname/etc/apache/conf.d"],
  }

}
