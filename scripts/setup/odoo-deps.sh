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

