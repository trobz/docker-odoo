set -e

echo "APT: install openoffice"

apt-get install -y \
    python-cairo python-openoffice python-uno python-lxml \
    openoffice.org

#JCD 2013-05-24: We must use genshi in version 0.6.1, version 0.7 is not compatible with OpenERP
echo "PIP: install python lib"

pip install genshi==0.6.1

echo "Get aeroo and manually setup it with python setup toolkit"

mkdir -p /tmp/setup/aeroo/

wget http://launchpad.net/aeroolib/trunk/1.0.0/+download/aeroolib.tar.gz -O /tmp/setup/aeroo/aeroolib.tar.gz
cd /tmp/setup/aeroo
tar xzf aeroolib.tar.gz
rm aeroolib.tar.gz
cd aero* ; python setup.py install

echo "Clean up..."

cd /tmp/setup/
rm -rf aeroo

echo "OpenOffice / Aeroo setup done !"