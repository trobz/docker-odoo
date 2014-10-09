#!/bin/bash

info "Setup PostgreSQL to allow external data/config/log storage..."

POSTGRESQL_VERSION="9.3"

export POSTGRESQL_USER=${POSTGRESQL_USER:-"openerp"}
export POSTGRESQL_PASS=${POSTGRESQL_PASS:-"openerp"}

POSTGRESQL_PUB="/etc/postgresql/docker"
POSTGRESQL_DATA=$POSTGRESQL_PUB/data
POSTGRESQL_LOG=$POSTGRESQL_PUB/log
POSTGRESQL_CONF=$POSTGRESQL_PUB/config
POSTGRESQL_DEF=$POSTGRESQL_PUB/defaults

POSTGRESQL_BIN="/usr/lib/postgresql/$POSTGRESQL_VERSION/bin/postgres"
POSTGRESQL_INIT="/usr/lib/postgresql/$POSTGRESQL_VERSION/bin/initdb"
POSTGRESQL_MAIN="/etc/postgresql/$POSTGRESQL_VERSION/main"

POSTGRESQL_SINGLE="$POSTGRESQL_BIN \
    --single \
    --config-file=$POSTGRESQL_CONF/postgresql.conf \
    -D $POSTGRESQL_DATA/db"

function exec_psql {
    cmd="$POSTGRESQL_SINGLE <<< \"$@\""
    sudo su postgres <<< $cmd &>/dev/null
}


set +e
ls $POSTGRESQL_DATA &>/dev/null
HAS_CONF_DIR=$?
set -e

if [[ $HAS_CONF_DIR -ne 0 ]]; then
    warn "the PostreSQL database will not be persistent and will be stored inside the container."
    warn "please, bind a folder on $POSTGRESQL_PUB to make it persistent..."
fi

# force the creation of postgres user-specific folders...
mkdir -p $POSTGRESQL_PUB/{data,log,config}


set +e
CONF_COUNT=$(sudo su postgres -c "ls $POSTGRESQL_CONF | wc -l")
[ $CONF_COUNT -ne 0 ]
HAS_USER_CONFIG=$?
set -e

#
# Prepare configuration folder
#

if [[ $HAS_USER_CONFIG -ne 0 ]]; then

    info "use default PostgreSQL configuration files"
    sudo cp $POSTGRESQL_DEF/* $POSTGRESQL_CONF

elif [[ $CONF_COUNT -ne 3 ]]; then

    error "you have specify a non empty configuration folder for PostgreSQL without all required config:"
    error "pg_hba.conf, pg_ident.conf, postgresql.conf"
    die

fi

#
# Prepare log folder
#

if [ ! -d $POSTGRESQL_LOG ]; then
    info "Create PostgreSQL log directory..."
    sudo mkdir -p $POSTGRESQL_LOG
fi
sudo chmod a+rwx $POSTGRESQL_LOG -R


sudo chown postgres: $POSTGRESQL_PUB -R
sudo chmod +rwx $POSTGRESQL_PUB -R
sudo chmod a-rwx,u+rwx $POSTGRESQL_DATA -R

#
# Prepare data folder
#

set +e
sudo su postgres -c "ls $POSTGRESQL_DATA/db &>/dev/null"
DATA_EXISTS=$?
set -e

if [[ $DATA_EXISTS -ne 0 ]]; then
    info "Create PostgreSQL public directory..."
    sudo su postgres -c "$POSTGRESQL_INIT -D $POSTGRESQL_DATA/db -E 'UTF-8'"
fi


#
# Setup extensions and default users
#
info "setup extensions and $POSTGRESQL_USER user"
exec_psql 'CREATE EXTENSION IF NOT EXISTS "unaccent";'
exec_psql "CREATE USER $POSTGRESQL_USER WITH SUPERUSER;"
exec_psql "ALTER USER $POSTGRESQL_USER WITH PASSWORD '$POSTGRESQL_PASS';"

success "PostgreSQL successfully configured"
