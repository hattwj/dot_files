wget http://ftp.de.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.8_all.deb
sudo dpkg -i ttf-mscorefonts-installer_3.8_all.deb

# consolas
mkdir consolas-font
cd consolas-font
wget http://download.microsoft.com/download/E/6/7/E675FFFC-2A6D-4AB0-B3EB-27C9F8C8F696/PowerPointViewer.exe
cabextract -L -F ppviewer.cab PowerPointViewer.exe
cabextract ppviewer.cab
cp *.TTF  /usr/share/fonts/truetype/msttcorefonts
cd ../
rm -rf consolas-font

sudo fc-cache -f -v
