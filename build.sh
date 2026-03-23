#!/data/data/com.termux/files/usr/bin/bash
set -e
VERSION=$(grep '"version":' manifest.json | cut -d '"' -f 4)
G='\033[0;92m'
NC='\033[0m'
msg() { printf "${G}==>${NC} $*\n"; }

# 1. Prep Workspace
msg "Cleaning old builds..."
rm -f *.deb termux/packages/*.deb

# 2. Compile Nim Components
msg "Compiling Gitmas and Shared Library..."
# Build the main binary
nim c -d:release --opt:size -o:src/gitmas src/gitmas.nim
strip src/gitmas

# New Game Binary
nim c -d:release --opt:size src/game.nim
strip src/game

# Build the shared library (The Auth/Sign Brain)
# We ensure it goes into the lib folder for the manifest to grab
nim c -d:release --app:lib --out:lib/libgitmas.so lib/gitmaslib.nim
strip lib/libgitmas.so

# 3. Build Debian Package
msg "Packaging $VERSION..."
termux-create-package manifest.json
mv *.deb termux/packages/

# 4. Repo Indexing
msg "Updating Repo Index..."
cd termux/packages
dpkg-scanpackages . /dev/null > Packages
gzip -9c Packages > Packages.gz

# 5. Signing (Using GPG Key)
msg "Generating Release & Signing..."
# If you don't have apt-ftparchive, a simple 'ls' based Release file works too
apt-ftparchive -c ../apt.conf release . > Release

gpg --batch --yes --pinentry-mode loopback --passphrase "" --clearsign -o InRelease Release
gpg --batch --yes --pinentry-mode loopback --passphrase "" -abs -o Release.gpg Release
cd ../.. 

# 6. Deployment
msg "Pushing to GitHub..."
gitmas push "$1"

msg "${G}$VERSION is Live and Signed!${NC}"
