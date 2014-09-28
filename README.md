## Description

This docker image setup a full openerp environment, with pre-installed PostgreSQL and LibreOffice headless services. 

A one-command quick installation script is available (Ubuntu 14.04 only):
```
curl -sSL https://raw.githubusercontent.com/trobz/docker-odoo/8.0/installer.sh  | /bin/bash
```

> Note:
The script is doing a lot for you, it will install [docker](http://docs.docker.com/installation/ubuntulinux/) and [fig](http://www.fig.sh/install.html), then pull the docker image from the hub and configure the container with a `fig.yml` file in `$HOME/docker/odoo-latest/`. It will also add the container into upstart config to automatically run it at the next host start up.

## Dependency

This image is based on `trobz/sshd` + his own dependencies.

## OS / Services

- Ubuntu 14.04.1 LTS
- Supervisord 3.0b2 
- PostgreSQL 9.3.5
- Python 2.7.6 / 3.4.0
- Odoo 8.0 + all required python packages (setup based on offical odoo `setup.py`)

## Features

### Odoo demo

If the env `ODOO_DEMO` is set to 1, the container will setup a Odoo instance for you by creating the database and adding a supervisord configuration for Odoo.

Then, you will have a running Odoo instance accessible on `http://localhost:<port-map-to-8069>/` out-of-the-box.
 

### PostgreSQL

PostgreSQL 9.3 is set up to store data, configuration and logs on external volume to keep databases persistent.

To keep your PostgreSQL database persistn, you have to bind a volume like this:
```
/path/on/host/postgres/data:/etc/postgresql/docker/data
/path/on/host/postgres/config:/etc/postgresql/docker/config
/path/on/host/postgres/log:/etc/postgresql/docker/log
```

### IDE remote debugging

The remote debugging can be auto-configured at start up, to enable it,
you have to bind the debugging python source from your IDE to a specific folder:

```
/path/to/IDE/debugging/source:/usr/local/lib/pydevd
```

The init script will automatically setup PyCharm and Eclipse debugger and update the default user `PYTHONPATH` to enable remote debugging.

## Ports

Several ports are exposed:
- `8069`: openerp service
- `5432`: PostgreSQL service
- `22`: ssh server (see `trobz/sshd` image)
- `8011`: supervisord http interface  (see `trobz/supervisord` image)
