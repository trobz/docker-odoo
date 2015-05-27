set -e

echo "Clone Odoo master from github"

git clone -b master https://github.com/odoo/odoo.git /usr/local/lib/odoo

echo "Odoo master setup done !"
