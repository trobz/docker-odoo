############################################################
# Fullstack OpenERP 8.0 server
############################################################

FROM trobz/sshd:14.04

MAINTAINER Michel Meyer <mmeyer@trobz.com>

# Prepare for the setup 
############################################################

RUN apt-get update
RUN apt-get install -y postgresql postgresql-contrib-9.3
RUN apt-get update && apt-get dist-upgrade -y

# Install all services
############################################################

# Common lib
ADD scripts/setup/common /tmp/setup/common
RUN /bin/bash < /tmp/setup/common/deps.sh
# OpenOffice + Aeroo
ADD scripts/setup/odoo /tmp/setup/odoo
RUN /bin/bash < /tmp/setup/odoo/deps.sh
RUN /bin/bash < /tmp/setup/odoo/source.sh

# Configure all services
############################################################

# postgresql

ADD config/postgres/ /etc/postgresql/docker/defaults
RUN chown postgres: /etc/postgresql/docker -R

# supervisor

ADD config/supervisor/postgres.conf /etc/supervisor/conf.d/postgres.conf

# update locate db
RUN updatedb

# change default user configuration
ENV USERNAME openerp
ENV PASSWORD openerp
ENV USER_HOME /opt/openerp
ENV ODOO_DEMO 0

# Add odoo 8.0 demo files
############################################################

ADD demo /tmp/setup/odoo/demo

# Finalization
############################################################

# expose openerp/postgres port
EXPOSE 8069 5432 22

# enable interactive debconf again
RUN echo 'debconf debconf/frontend select Dialog' | debconf-set-selections

ADD scripts/start/init/20_postgres.sh /usr/local/docker/start/init/20_postgres.sh
ADD scripts/start/init/25_virtual_env.sh /usr/local/docker/start/init/25_virtual_env.sh
ADD scripts/start/init/30_remote_debug.sh /usr/local/docker/start/init/30_remote_debug.sh
ADD scripts/start/init/40_demo_odoo.sh /usr/local/docker/start/init/40_demo_odoo.sh
