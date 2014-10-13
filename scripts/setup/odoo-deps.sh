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
pip install pyPdf python-dime unidecode prestapyt requests xlsxwriter egenix-mx-base

echo "Install webkit2pdf command"

WTH_VERSION="0.12.1"
UBUNTU_ARCHI=`uname -a | grep 64 &>/dev/null; [ $? -eq 0 ] && echo 'amd64' || echo 'i386'`
UBUNTU_CODE=`lsb_release -a 2>/dev/null | grep Codename  | sed 's/.*\:\t*//'`
WTH_BASE_URL="http://sourceforge.net/projects/wkhtmltopdf/files/%s/wkhtmltox-%s_linux-%s-%s.deb/download"
WTH_URL=`printf $WTH_BASE_URL $WTH_VERSION $WTH_VERSION $UBUNTU_CODE $UBUNTU_ARCHI`

echo "- download wkhtmltopdf $WTH_VERSION deb package for ubuntu $UBUNTU_CODE..."
echo "  package url: $WTH_URL"
wget  "$WTH_URL" -O /tmp/wkhtmltopdf.deb

echo "- install wkhtmltopdf deb package..."
dpkg -i /tmp/wkhtmltopdf.deb

echo "- clean up installation folder..."
rm -f /tmp/wkhtmltopdf.deb

echo "Install pychart manually (pip package doesn't exists anymore)"

mkdir -p /tmp/setup/pychart/
wget http://download.gna.org/pychart/PyChart-1.39.tar.gz -O /tmp/setup/pychart/pychart.tar.gz
cd /tmp/setup/pychart && tar xzf pychart.tar.gz && cd PyChart-1.39 && python setup.py install

