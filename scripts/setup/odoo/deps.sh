set -e

echo "Install webkit2pdf command"

WTH_VERSION="0.12.2.1"
UBUNTU_ARCHI=`uname -a | grep 64 &>/dev/null; [ $? -eq 0 ] && echo 'amd64' || echo 'i386'`
UBUNTU_CODE=`lsb_release -a 2>/dev/null | grep Codename  | sed 's/.*\:\t*//'`
WTH_BASE_URL="http://download.gna.org/wkhtmltopdf/0.12/%s/wkhtmltox-%s_linux-%s-%s.deb"
WTH_URL=`printf $WTH_BASE_URL $WTH_VERSION $WTH_VERSION $UBUNTU_CODE $UBUNTU_ARCHI`

echo "- download wkhtmltopdf $WTH_VERSION deb package for ubuntu $UBUNTU_CODE..."
echo "  package url: $WTH_URL"

wget  "$WTH_URL" -O /tmp/wkhtmltopdf.deb
dpkg -i /tmp/wkhtmltopdf.deb
rm -f /tmp/wkhtmltopdf.deb

