# Puppet Projects

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with projects](#setup)
    * [What projects affects](#what-projects-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with projects](#beginning-with-projects)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module provide a standard "Project Layout" for various applications (mainly web applications). It currently supports:

* Apache
* Tomcat
* MySQL


## Module Description

A project is a standard structured area where non-privilidged users can
configure and deploy pre-defined services.  The default base location for
projects is `/srv/projects/<projectname>`, but can be changed using the
`::projects::basedir` parameter.


## Setup



### What projects affects

* Files and directories under `::projects::basedir` (default `/srv/projects/`).
* Apache vhosts.
* Tomcat instances, services and AJP connectors.
* A local "project user" is created for each project. Matching the project shortname and using the UID as specified in the `uid` key.
* A local "project group" is created for each project.

### Setup Requirements

Reading project data from hiera requires `merge_behaviour` to be set to `deeper` in hiera. This can be done by adding `:merge_behavior: deeper` to `/etc/puppet/hiera.yaml`.

### Beginning with projects

It's intended that projects are defined in hiera under the `projects` top-level hash. To start, include the module in your puppet manifests:

```
include projects
```

An example hiera hash is as follows:

```yaml
projects:
  'myproject':
    description: 'My Tomcat service'
    uid: 6666
    gid: 6666
    users:
      - alice
      - bob
    apache:
      'site.example.com':
        port: 80
      'site.example.com-ssl':
        vhost_name: 'site.example.com'
        port: 443
        ssl: true
    tomcat:
      ajp_port: 8009
```


## Usage

Once the `projects` class is included. You can start by building up the hiera data structure. By using the `deeper` hiera merge, you can seperate common a per-instance data.

The key for the hash entry is the project shortname.

### Common Data

The following hash keys under the project shortname are used for common data. It is advised that this it put in your common yaml file:

* `decription`: A Line scribing the project
* `uid`: The UID of the project user. 
* `gid`: The GID of the project user.
* `users`: An array of users that a members of the project.

### Apache

The `apache` key contains a hash for virtualhost to configure for the project. Each key in this hash is a virtualhost to configure (therefore you can have multiple virtualhosts). Each virtualhost key has the following configuration parameters.

* `port`: The port for the virtualhost to listen on (default: 80).
* `vhost_name`: The name for the Name-base Virtual Host to respond for (default: the vhost key).
* `ssl`: Enable SSL? (default: no).

### Tomcat

The `tomcat` key declares that a tomcat instance should be installed for this project. It's value is a hash that can contain the following values:

* `ajp_port`: 

## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

This is where you list OS compatibility, version compatibility, etc.

## Development

Pull requests are gratefully received.
