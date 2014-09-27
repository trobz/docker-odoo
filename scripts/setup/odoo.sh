set -e

echo "Clone Odoo master from github and setup it with pip"

git clone -b master --single-branch https://github.com/odoo/odoo.git /usr/local/lib/odoo
cd /usr/local/lib/odoo && pip install -ve .

echo "Odoo master setup done !"
