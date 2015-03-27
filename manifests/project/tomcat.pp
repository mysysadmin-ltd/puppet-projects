# -- Resource type: project::tomcat
#
# Defines an tomcat service
define projects::project::tomcat (
  $port = 8005,
  $ajp_port = 8009,
) {

  $catalina_home = "$::projects::basedir/$title/lib/tomcat"

  file { "$catalina_home":
    ensure  => directory,
    owner   => $::tomcat::user,
    group   => $title,
    mode    => 0770,
    require => File["$::projects::basedir/$title/lib"],
  }

  tomcat::instance { "$title":
    install_from_source => true,
    source_url          => 'http://mirror.vorboss.net/apache/tomcat/tomcat-8/v8.0.20/bin/apache-tomcat-8.0.20.tar.gz',
    catalina_home       => $catalina_home,
    catalina_base       => $catalina_home,
  }->
  tomcat::service { "$title":
    catalina_home => $catalina_home,
    catalina_base => $catalina_home,
  }->
  tomcat::config::server { "$title":
    catalina_base => $catalina_home,
    port          => $port,
  }->
  tomcat::config::server::connector { "ajp-$title":
    catalina_base => $catalina_home,
    port          => $ajp_port,
    protocol      => 'AJP/1.3',
  }

  file { "$::projects::basedir/$title/var/webapps":
    ensure  => directory,
    owner   => $::tomcat::user,
    group   => $title,
    mode    => 0770,
    require => File["$::projects::basedir/$title/var"],
  }

  # We symlink this way around to forceably remove the default webapps that tomcat provides.
  file { "$catalina_home/webapps":
    ensure  => link,
    target  => "$::projects::basedir/$title/var/webapps",
    owner   => $::tomcat::user,
    group   => $title,
    mode    => 0770,
    require => Tomcat::Instance["$title"],
    force   => true,
    backup  => false, # The java apps are just too big to filebucket
  }

  file { "$::projects::basedir/$title/var/log/tomcat":
    ensure  => link,
    target  => "$catalina_home/logs",
    owner   => $::tomcat::user,
    group   => $title,
    mode    => 0750,
    require => File["$::projects::basedir/$title/var/log"],
  }


}
