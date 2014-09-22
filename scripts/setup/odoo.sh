set -e

echo "Get Odoo 7.0 and manually setup it with python setup toolkit"

mkdir -p /tmp/setup/odoo/

wget http://nightly.openerp.com/7.0/nightly/src/openerp-7.0-latest.tar.gz  -O /tmp/setup/odoo/openerp-7.0.tar.gz
cd /tmp/setup/odoo/
tar xzf openerp-7.0.tar.gz
rm openerp-7.0.tar.gz

cd openerp*
# we just want to install dependencies as defined in the setup.py file, not installing openerp in the python lib folder
# so first, let's remove packaging stuffs for the setup.py
cp setup.py install.py
sed -i 's/packages=.*/packages='',/g' install.py
sed -i 's/package_dir=.*//g' install.py
sed -i 's/include_package_data=True/include_package_data=False/g' install.py
python install.py install

echo "Clean up..."

cd /tmp/setup

# keep official source, required if the container is started in demo mode
mv /tmp/setup/odoo/openerp* /usr/local/lib/openerp

echo "Odoo setup done !"
