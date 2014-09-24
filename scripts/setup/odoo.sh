set -e

echo "Clone Odoo 8.0 from github and setup it with pip"

git clone -b 8.0 --single-branch https://github.com/odoo/odoo.git /usr/local/lib/odoo
cd /usr/local/lib/odoo && pip install -ve .

echo "Odoo 8.0 setup done !"
