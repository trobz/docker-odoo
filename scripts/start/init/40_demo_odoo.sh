if [[ $ODOO_DEMO -eq 1 ]]; then
    set -e

    info 'Setup a Odoo 7.0 demo instance'
    
    debug 'temporary start postgres service'

    DEMODB="demo_odoo70"
    PGPATH="/etc/postgresql/docker/" 
    PGEXEC="/usr/lib/postgresql/9.1/bin"
    OOEXEC="/usr/local/lib/odoo/openerp-7.0/openerp-server"
    PGPIDFILE="/var/run/postgresql/9.1-main.pid"

    sudo -u postgres -H $PGEXEC/pg_ctl start -w -D $PGPATH/data/db &>/dev/null
        
    set +e ; sudo -u $USERNAME -H psql -l | grep $DEMODB &>/dev/null ; DB_EXISTS=$? ; set -e
    if [[ $DB_EXISTS -ne 0 ]] ; then  
        info "Create and initalize database $DEMODB"
        sudo -u $USERNAME -H createdb $DEMODB 
        sudo -u $USERNAME -H $OOEXEC -d $DEMODB --init base --stop-after-init
    else
        warn "$DEMODB already exists, skip database initialization"
    fi

    debug "terminate postgres service"
    sudo -u postgres -H $PGEXEC/pg_ctl stop -D $PGPATH/data/db  &>/dev/null

    info 'Configure the demo instance to automatically start with supervisord'
    cp /tmp/setup/odoo/demo/odoo_demo.conf /etc/supervisor/conf.d/odoo_demo.conf
    
fi

