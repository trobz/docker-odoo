set -e

echo "Clone Odoo 8.0 from github"

git clone -b 8.0 https://github.com/odoo/odoo.git /usr/local/lib/odoo

echo "Odoo 8.0 setup done !"
