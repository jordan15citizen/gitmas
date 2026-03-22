echo "- Building debian package..."
nim -d:release --opt:size c src/gitmas.nim
termux-create-package manifest.json
echo "- Moving debian package to termux/packagrs..."
mv ./*.deb termux/packages
cd termux/packages
dpkg-scanpackages . /dev/null > Packages
gzip -9c Packages > Packages.gz
echo "- Publishing to GitHub..."
gitmas push "$1"