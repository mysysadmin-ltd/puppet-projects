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

  file { "$::projects::basedir/$title/var/log/httpd":
    ensure  => directory,
    owner   => $apache_user,
    group   => $title,
    mode    => 0750,
    seltype => 'var_log_t',
    require => File["$::projects::basedir/$title/var/log"],
  }

  file { "$::projects::basedir/$title/etc/apache":
    ensure  => directory,
    owner   => $title,
    group   => $title,
    require => File["$::projects::basedir/$title/etc"],
  }

  file { "$::projects::basedir/$title/etc/apache/conf.d":
    ensure  => directory,
    owner   => $apache_user,
    group   => $title,
    mode    => 0770,
    seltype => 'httpd_config_t',
    require => File["$::projects::basedir/$title/etc/apache"],
  }

  create_resources('::projects::project::apache::vhost', $vhosts, {
    'projectname' => $title,
    'apache_user' => $apache_user
  })
}

# -- Resource type: project::apache::vhost
#
# Configures and projec apache vhost.
define projects::project::apache::vhost (
  $projectname = undef,
  $docroot = undef,
  $port = i80,
  $vhost_name = $title,
  $ssl = false,
  $apache_user = 'apache',
) {

  file { "$::projects::basedir/$projectname/etc/apache/conf.d/$title":
    ensure      => directory,
    owner       => $apache_user,
    group       => $projectname,
    seltype     => 'httpd_config_t',
    require     => File["$::projects::basedir/$projectname/etc/apache/conf.d"],
  }

  ::apache::vhost { $title:
    port                => $port,
    vhost_name          => $host_name,
    ssl                 => $ssl,
    docroot             => "$::projects::basedir/$projectname/var/www",
    logroot             => "$::projects::basedir/$projectname/var/log/httpd",
    additional_includes => ["$::projects::basedir/$projectname/etc/apache/conf.d/","$::projects::basedir/$projectname/etc/apache/conf.d/$title/"]
  }

}
