set -e

echo "APT: install Odoo default libs"

echo ttf-mscorefonts-installer	msttcorefonts/accepted-mscorefonts-eula	boolean	true | /usr/bin/debconf-set-selections
apt-get update
apt-get dist-upgrade -y
apt-get install -y \
    libxml2-dev libxslt1-dev libpq-dev libldap2-dev libsasl2-dev libssl-dev libffi-dev \
    python python-dev \
    fontconfig fontconfig-config graphviz ghostscript gsfonts ttf-mscorefonts-installer

echo "Add jpeg support (for pillow)"

apt-get install -y \
    libjpeg-dev libfreetype6-dev zlib1g-dev

ln -s /usr/lib/`uname -i`-linux-gnu/libfreetype.so /usr/lib/
ln -s /usr/lib/`uname -i`-linux-gnu/libjpeg.so /usr/lib/
ln -s /usr/lib/`uname -i`-linux-gnu/libz.so /usr/lib/

echo "PIP: install the latest version"

curl https://bootstrap.pypa.io/get-pip.py | python

echo "PIP: install OpenSSL lib"

pip install pyopenssl ndg-httpsclient pyasn1 wheel pew
