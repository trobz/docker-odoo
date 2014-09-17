if [[ $ODOO_DEMO -eq 1 ]]; then
    info 'Setup a Odoo 7.0 demo instance'

    sudo su postgres -H createdb odoo_demo70 -O openerp &>/dev/null
    sudo su postgres -H psql odoo_demo70 < /tmp/setup/odoo/demo/odoo.sql 1>/dev/null

    info 'Configure the demo instance to automatically start with supervisord'
    cp /tmp/setup/odoo/demo/odoo_demo.conf /etc/supervisor/conf.d/odoo_demo.conf

fi