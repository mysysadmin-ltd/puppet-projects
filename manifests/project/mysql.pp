# -- Resource type: project::tomcat
#
# Defines an mysql instance
define projects::project::mysql (
  $host = 'localhost',
  $grant = ['ALL'],
  $user = $title,
  $password = 'changeme'
) {

  concat::fragment { "${title} mysql":
    target  => "${::projects::basedir}/${title}/README",
    content => "MySQL:
  host: ${host}
  grant: ${grant}
  username: ${user}
  password: ${password}\n",
    order   => '10'
  }

  if !defined(Class['::mysql::server']) {
    class { '::mysql::server':
      $root_password => hiera('projects::mysql::root_password','')
    }
  }

  mysql::db { "$title":
    user     => $user,
    password => $password,
    host     => $host,
    grant    => $grant
  }


}
