set -e

echo "APT: install Odoo default libs"

echo ttf-mscorefonts-installer	msttcorefonts/accepted-mscorefonts-eula	boolean	true | /usr/bin/debconf-set-selections

apt-get install -y \
    python-dateutil python-feedparser python-gdata python-ldap \
    python-libxslt1 python-lxml python-mako python-openid python-psycopg2 \
    python-pybabel python-pychart python-pydot python-pyparsing python-reportlab \
    python-simplejson python-tz python-vatnumber python-vobject python-webdav \
    python-werkzeug python-xlwt python-yaml python-zsi \
    python-pip python-dev \
    fontconfig fontconfig-config graphviz ghostscript gsfonts ttf-mscorefonts-installer

echo "PIP: install useful python libs"

pip install httplib2 sqlparse qunitsuite configobj
pip install pyPdf python-dime unidecode prestapyt requests xlsxwriter


echo "Get Odoo 7.0 and manually setup it with python setup toolkit"

mkdir -p /tmp/setup/odoo/

wget http://nightly.openerp.com/7.0/nightly/src/openerp-7.0-latest.tar.gz  -O /tmp/setup/odoo/openerp-7.0.tar.gz
cd /tmp/setup/odoo/
tar xzf openerp-7.0.tar.gz
rm openerp-7.0.tar.gz
cd openerp* ; python setup.py install

echo "Clean up..."

cd /tmp/setup

# we don't keep openerp installed in python packages to avoid conflict with Odoo source code in development
echo 'ls packages'
ls -lah /usr/local/lib/python2.7/dist-packages/

echo 'ls openerp'
ls -lah /usr/local/lib/python2.7/dist-packages/openerp*

#mv /usr/local/lib/python2.7/dist-packages/openerp-* /usr/local/lib/openerp

echo "Odoo setup done !"
