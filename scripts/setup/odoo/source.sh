set -e

echo "Clone Odoo 7.0 from github"

git clone --depth 1 -b 7.0 https://github.com/odoo/odoo.git /usr/local/lib/odoo

echo "Odoo 7.0 setup done !"
