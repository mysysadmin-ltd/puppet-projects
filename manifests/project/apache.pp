# -- Resource type: project::apache
#
# Defines an apache project
define projects::project::apache (
  $vhosts = {},
  $apache_user = 'apache'
) {
  if !defined(Class['::apache']) {
    include ::apache
    include ::apache::mod::proxy
    include ::apache::mod::proxy_http
  }

  # installing apache doesn't appear to pull in these deps. Problem with the RPM or the puppetlabs/apache module?
  package { ['apr', 'apr-util']:
    ensure => present
  }

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

  file { "/etc/logrotate.d/httpd-$title":
    ensure  => present,
    content => template('projects/apache/logrotate.erb'),
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

  file { "$::projects::basedir/$title/etc/ssl":
    ensure  => directory,
    owner   => $title,
    group   => $title,
    require => File["$::projects::basedir/$title/etc"],
  }

  file { [ "$::projects::basedir/$title/etc/ssl/private",
           "$::projects::basedir/$title/etc/ssl/certs",
           "$::projects::basedir/$title/etc/ssl/csrs",
           "$::projects::basedir/$title/etc/ssl/conf"] :
    ensure  => directory,
    owner   => $title,
    group   => $title,
    require => File["$::projects::basedir/$title/etc/ssl"],
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
  $port = 80,
  $vhost_name = $title,
  $ssl = false,
  $apache_user = 'apache',
  $altnames = []
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
    vhost_name          => $vhost_name,
    ssl                 => $ssl,
    docroot             => "$::projects::basedir/$projectname/var/www",
    logroot             => "$::projects::basedir/$projectname/var/log/httpd",
    additional_includes => ["$::projects::basedir/$projectname/etc/apache/conf.d/","$::projects::basedir/$projectname/etc/apache/conf.d/$title/"],
    ssl_cert            => "$::projects::basedir/$projectname/etc/ssl/certs/$vhost_name.crt",
    ssl_key             => "$::projects::basedir/$projectname/etc/ssl/private/$vhost_name.key",
  }

  file {'$::projects::basedir/$projectname/etc/ssl/conf/$vhost_name.cnf':
    content => template('openssl/cert.cnf.erb')
  }

  ssl_pkey { '$::projects::basedir/$projectname/etc/ssl/private/$vhost_name.key' :
  }


  if !defined(Firewall["050 accept Apache $port"]) {
    firewall { "050 accept Apache $port":
      port   => $port,
      proto  => tcp,
      action => accept,
    }
  }

}
