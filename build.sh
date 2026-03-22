rm -rf termux/packages/*.deb
rm -rf lib/*.so
echo "- Building debian package..."
nim -d:release --opt:size c src/gitmas.nim
strip src/gitmas
cd lib
nim c -d:release --app:lib --out:libgitsetup.so git_setup.nim
cd ..
termux-create-package manifest.json
echo "- Moving debian package to termux/packagrs..."
mv ./*.deb termux/packages
cd termux/packages
dpkg-scanpackages . /dev/null > Packages
gzip -9c Packages > Packages.gz
echo "- Publishing to GitHub..."
gitmas push "$1"