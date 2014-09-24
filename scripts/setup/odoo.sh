set -e

echo "Clone Odoo 7.0 from github and setup it with pip"

git clone -b 7.0 https://github.com/odoo/odoo.git /usr/local/lib/odoo
cd /usr/local/lib/odoo && pip install -ve .

echo "Odoo 7.0 setup done !"
