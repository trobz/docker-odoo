############################################################
# Fullstack OpenERP 7.0 server
############################################################

FROM trobz/sshd:12.04

MAINTAINER Michel Meyer <mmeyer@trobz.com>

# Install postgreSQL
############################################################

RUN apt-get install -y postgresql postgresql-contrib-9.1

# Run the official OpenERP prepare scripts
############################################################

ADD scripts/setup/odoo.sh /tmp/setup/odoo/odoo.sh
RUN /bin/bash < /tmp/setup/odoo/odoo.sh

# Install OpenOffice + Aeroo
############################################################

ADD scripts/setup/aeroo.sh /tmp/setup/aeroo/aeroo.sh
RUN /bin/bash < /tmp/setup/aeroo/aeroo.sh

# Configure all services
############################################################

# postgresql

ADD config/postgres/ /etc/postgresql/docker/defaults
RUN chown postgres: /etc/postgresql/docker -R

# supervisor

ADD config/supervisor/postgres.conf /etc/supervisor/conf.d/postgres.conf
ADD config/supervisor/openoffice.conf /etc/supervisor/conf.d/openoffice.conf
ADD config/init/openoffice-headless /etc/init.d/openoffice-headless

# tms admin
ADD config/tms-admin/config.ini /tmp/tms_admin_config.ini

# update locate db
RUN updatedb

# change default user configuration
ENV USERNAME openerp
ENV PASSWORD openerp
ENV USER_HOME /opt/openerp

# Finalization
############################################################

# expose openerp/postgres port
EXPOSE 8069 5432 22

# enable interactive debconf again
RUN echo 'debconf debconf/frontend select Dialog' | debconf-set-selections

ADD scripts/start/init/10_git.sh /usr/local/docker/start/init/10_git.sh
ADD scripts/start/init/20_postgres.sh /usr/local/docker/start/init/20_postgres.sh
ADD scripts/start/init/30_remote_debug.sh /usr/local/docker/start/init/30_remote_debug.sh
ADD scripts/start/init/40_tms_toolkit.sh /usr/local/docker/start/init/40_tms_toolkit.sh
