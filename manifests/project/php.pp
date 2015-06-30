# -- Resource type: project::php
#
# Defines php services
define projects::project::php () {
  class {'::apache::mod::php':
  }
}
