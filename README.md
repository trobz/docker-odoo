## Description

This docker image setup a full openerp environment, with pre-installed PostgreSQL and LibreOffice headless services.

## Dependency

This image is based on `trobz/sshd` + his own dependencies.

## Features

### PostgreSQL

PostgreSQL 9.1 is set up to store data, configuration and logs on external volume to keep databases persistent.

To keep your PostgreSQL database persistn, you have to bind a volume like this:
```
/path/on/host/postgres/data:/etc/postgresql/docker/data
/path/on/host/postgres/config:/etc/postgresql/docker/config
/path/on/host/postgres/log:/etc/postgresql/docker/log
```

### Gitlab configuration

Trobz private gitlab instance is auto-configured at the first start up, you have to use environment variables to customize
git configuration:

```
GIT_USERNAME=Michel Meyer
GIT_EMAIL=mmeyer@trobz.com
```

### IDE remote debugging

The remote debugging can be auto-configured at start up, to enable it,
you have to bind the debugging python source from your IDE to a specific folder:

```
/path/to/IDE/debugging/source:/opt/openerp/lib/pydevd
```

The init script will automatically setup PyCharm and Eclipse debugger and update the default user `PYTHONPATH` to enable
remote debugging.

Note: You have to run OpenERP with the customized `server-trobz` server to enable remote debugging.

### LibreOffice

LibreOffice is pre-configured and is managed by supervisor, it should work out-of-the-box.

## Ports

Several ports are exposed:
- `8069`: openerp service
- `5432`: PostgreSQL service
- `22`: ssh server (see `trobz/sshd` image)
- `8011`: supervisord http interface  (see `trobz/supervisord` image)
