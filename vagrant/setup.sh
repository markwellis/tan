#!/bin/bash
set -euo pipefail

sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    build-essential \
    postgresql-9.6 \
    postgresql-server-dev-9.6 \
    apache2 \
    libssl-dev \
    libxml2-dev \
    libexpat1-dev \
    postfix

sudo cp -r /vagrant/vagrant/files/* /

sudo a2dissite 000-default
sudo a2ensite tan
sudo a2enmod rewrite headers proxy proxy_http ssl

sudo systemctl enable apache2
sudo systemctl restart apache2

curl -L https://install.perlbrew.pl | bash

#perlbrew init
echo "source ~/perl5/perlbrew/etc/bashrc" >> ~/.profile

set +euo pipefail
source ~/perl5/perlbrew/etc/bashrc
perlversion="5.22.4"
#"-D useshrplib" is needed to install Alien::ImageMagick
perlbrew install 5.22.4 -D useshrplib -j4 -n
perlbrew switch perl-5.22.4
perlbrew install-cpanm
set -euo pipefail

cpanm --notest Carton

pushd /vagrant

sudo mkdir -p /var/www/vhosts/
sudo ln -s /vagrant/ /var/www/vhosts/thisaintnews.com
mkdir -p share/{salt,sessions}

carton install

sudo -u postgres createuser thisaintnews
sudo -u postgres createdb tan
echo "alter user thisaintnews with encrypted password 'tan';" | sudo -u postgres psql
echo "grant all privileges on database tan to thisaintnews;" | sudo -u postgres psql
carton exec -- perl ./bin/db_manager.pl deploy

#this file is installed to the vm, not the shared folder. if it doesn't exist then probably the
# vm was destroyed and rebuilt, but the deps were already insalled via carton on the previous run
if [[ ! -e ~"/perl5/perlbrew/perls/perl-${perlversion}/lib/libMagickCore-7.Q16HDRI.so.6" ]]; then
    carton exec -- cpanm -n --reinstall Alien::ImageMagick
fi
