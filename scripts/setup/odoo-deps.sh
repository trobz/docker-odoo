set -e

echo "APT: install Odoo default libs"

echo ttf-mscorefonts-installer	msttcorefonts/accepted-mscorefonts-eula	boolean	true | /usr/bin/debconf-set-selections

apt-get install -y \
    python-pip python-dev \
    fontconfig fontconfig-config graphviz ghostscript gsfonts ttf-mscorefonts-installer

echo "PIP: install useful python libs"

pip install httplib2 sqlparse qunitsuite configobj
pip install pyPdf python-dime unidecode prestapyt requests xlsxwriter

