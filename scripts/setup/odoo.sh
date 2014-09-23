set -e

echo "Get Odoo 7.0 and manually setup it with pip"

mkdir -p /usr/local/lib/odoo/

wget http://nightly.openerp.com/7.0/nightly/src/openerp-7.0-latest.tar.gz  -O /usr/local/lib/odoo/openerp-7.0.tar.gz

cd /usr/local/lib/odoo/
tar xzf openerp-7.0.tar.gz && rm openerp-7.0.tar.gz && mv openerp-7.0* openerp-7.0
cd openerp-7.0

pip install -ve .

echo "Odoo setup done !"
