set -e

echo "APT: install Odoo default libs"

echo ttf-mscorefonts-installer	msttcorefonts/accepted-mscorefonts-eula	boolean	true | /usr/bin/debconf-set-selections

apt-get install -y \
    libxml2-dev libxslt1-dev libpq-dev libldap2-dev libsasl2-dev libssl-dev \
    python-pip python-dev \
    fontconfig fontconfig-config graphviz ghostscript gsfonts ttf-mscorefonts-installer

echo "Add jpeg support to PIL"

apt-get install -y \
    python-dev libjpeg-dev libfreetype6-dev zlib1g-dev

ln -s /usr/lib/`uname -i`-linux-gnu/libfreetype.so /usr/lib/
ln -s /usr/lib/`uname -i`-linux-gnu/libjpeg.so /usr/lib/
ln -s /usr/lib/`uname -i`-linux-gnu/libz.so /usr/lib/

echo "PIP: install useful python libs"

pip install httplib2 sqlparse qunitsuite configobj
pip install pyPdf python-dime unidecode prestapyt requests xlsxwriter

