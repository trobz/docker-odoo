if [[ $ODOO_DEMO -eq 1 ]]; then
    set -e

    info 'Setup a Odoo 8.0 demo instance'
    
    DEMODB="demo_odoo80"
    PGPATH="/etc/postgresql/docker" 
    OOPATH="/usr/local/lib/odoo"
    PGEXEC="/usr/lib/postgresql/9.3/bin"
    OOEXEC="$OOPATH/openerp-server"

    info 'Update Odoo 8.0 source code'
    cd $OOPATH && git pull origin 8.0

    debug 'temporary start postgres service'
    sudo -u postgres -H $PGEXEC/pg_ctl start -w -D $PGPATH/data/db &>/dev/null
        
    set +e ; sudo -u $USERNAME -H psql -l | grep $DEMODB &>/dev/null ; DB_EXISTS=$? ; set -e
    if [[ $DB_EXISTS -ne 0 ]] ; then  
        info "Create and initalize database $DEMODB"
        sudo -u $USERNAME -H createdb $DEMODB 
        sudo -u $USERNAME -H pew in $VENV $OOEXEC -d $DEMODB --init base --stop-after-init
    else
        warn "$DEMODB already exists, skip database initialization"
    fi

    debug "terminate postgres service"
    sudo -u postgres -H $PGEXEC/pg_ctl stop -D $PGPATH/data/db  &>/dev/null

    info 'Configure the demo instance to automatically start with supervisord'
    cp /tmp/setup/odoo/demo/odoo_demo.conf /etc/supervisor/conf.d/odoo_demo.conf
    replace_env /etc/supervisor/conf.d/odoo_demo.conf
fi

