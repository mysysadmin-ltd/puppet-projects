# -- Resource type: project::tomcat
#
# Defines an mysql instance
define projects::project::mysql (
  $host = 'localhost',
  $grant = ['ALL'],
  $user = $title,
  $password = 'changeme'
) {

  if !defined(Class['::mysql::server']) {
    class { '::mysql::server':
    }
  }

  mysql::db { "$title":
    user     => $user,
    password => $password,
    host     => $host,
    grant    => $grant
  }


}
