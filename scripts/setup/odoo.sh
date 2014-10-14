set -e

echo "Clone Odoo master from github and setup it with pip"

git clone -b master --single-branch https://github.com/odoo/odoo.git /usr/local/lib/odoo
cd /usr/local/lib/odoo && pip install -ve .

# remove /usr/local/lib/odoo pip reference to avoid conflicts with other odoo source
TMP=$(mktemp)
TARGET="/usr/local/lib/python2.7/dist-packages/easy-install.pth"
cat "$TARGET" | grep -v "/usr/local/lib/odoo" > "$TMP"
mv "$TMP" "$TARGET"
chmod +r "$TARGET"

echo "Odoo master setup done !"
