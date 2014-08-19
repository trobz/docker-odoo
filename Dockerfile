############################################################
# Fullstack OpenERP 7.0 server
############################################################

FROM trobz/sshd:12.04

MAINTAINER Michel Meyer <mmeyer@trobz.com>


# Install postgreSQL
############################################################

RUN apt-get install -y postgresql postgresql-contrib-9.1

# Install OpenERP required libs
############################################################

RUN apt-get install -y \
    python-dateutil python-feedparser python-gdata python-ldap \
    python-libxslt1 python-lxml python-mako python-openid python-psycopg2 \
    python-pybabel python-pychart python-pydot python-pyparsing python-reportlab \
    python-simplejson python-tz python-vatnumber python-vobject python-webdav \
    python-werkzeug python-xlwt python-yaml python-zsi \
    python-pip python-dev

# Run the official OpenERP prepare scripts
############################################################

ADD http://nightly.openerp.com/7.0/nightly/src/openerp-7.0-latest.tar.gz /tmp/setup/odoo/openerp-7.0.tar.gz
WORKDIR /tmp/setup/odoo/
RUN tar xzf openerp-7.0.tar.gz
RUN rm openerp-7.0.tar.gz
RUN cd openerp* ; python setup.py install
RUN rm -rf /usr/local/lib/python2.7/dist-packages/openerp-*

RUN pip install \
    sqlparse qunitsuite configobj

# Install OpenOffice + Aeroo
############################################################

RUN apt-get install -y \
    python-cairo python-openoffice python-uno python-lxml \
    openoffice.org
    
#JCD 2013-05-24: We must use genshi in version 0.6.1, version 0.7 is not compatible with OpenERP
RUN pip install genshi==0.6.1 

ADD http://launchpad.net/aeroolib/trunk/1.0.0/+download/aeroolib.tar.gz /tmp/setup/aeroo/aeroolib.tar.gz
WORKDIR /tmp/setup/aeroo
RUN tar xzf aeroolib.tar.gz
RUN rm aeroolib.tar.gz
RUN cd aero* ; python setup.py install

# jasper dependencies
RUN pip install httplib2 pyPdf python-dime unidecode

# prestashop dependencies
RUN pip install prestapyt

# font dependencies for report engines, require multiverse sources
RUN echo ttf-mscorefonts-installer	msttcorefonts/accepted-mscorefonts-eula	boolean	true | /usr/bin/debconf-set-selections
RUN apt-get install -y fontconfig fontconfig-config graphviz ghostscript gsfonts ttf-mscorefonts-installer

# Configure all services
############################################################

# postgresql

COPY config/postgres/ /etc/postgresql/docker/defaults
RUN chown postgres: /etc/postgresql/docker -R

# supervisor

COPY config/supervisor/postgres.conf /etc/supervisor/conf.d/postgres.conf
COPY config/supervisor/openoffice.conf /etc/supervisor/conf.d/openoffice.conf
COPY config/init/openoffice-headless /etc/init.d/openoffice-headless

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
