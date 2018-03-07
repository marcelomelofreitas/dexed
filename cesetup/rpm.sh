ver=`cat version.txt`
maj=${ver:0:1}
ver=${ver:1:100}
dte=$(LC_TIME='en_EN.UTF-8' date -u +"%a %b %d %Y")
arch=`uname -m`
specname=coedit-$arch.spec

semver_regex() {
  local VERSION="([0-9]+)[.]([0-9]+)[.]([0-9]+)"
  local INFO="([0-9A-Za-z-]+([.][0-9A-Za-z-]+)*)"
  local PRERELEASE="(-${INFO})"
  local METAINFO="([+]${INFO})"
  echo "^${VERSION}${PRERELEASE}?${METAINFO}?$"
}

SEMVER_REGEX=`semver_regex`
unset -f semver_regex

semver_parse() {
  echo $ver | sed -E -e "s/$SEMVER_REGEX/\1 \2 \3 \5 \8/" -e 's/  / _ /g' -e 's/ $/ _/'
}

string=
IFS=' ' read -r -a array <<< `semver_parse`
maj="${array[0]}"
min="${array[1]}"
pch="${array[2]}"
lbl="${array[3]}"

if [ $lbl == '_' ]; then
    lbl='0'
fi

buildroot=$HOME/rpmbuild/BUILDROOT/coedit-$maj.$min.$pch-$lbl.$arch
bindir=$buildroot/usr/bin
pixdir=$buildroot/usr/share/pixmaps
shcdir=$buildroot/usr/share/applications

mkdir -p $buildroot
mkdir -p $bindir
mkdir -p $pixdir
mkdir -p $shcdir

cp nux64/coedit $bindir
cp nux64/dastworx $bindir
cp nux64/coedit.png $pixdir

echo "[Desktop Entry]
Categories=Application;IDE;Development;
Exec=coedit %f
GenericName=coedit
Icon=coedit
Keywords=editor;Dlang;IDE;dmd;
Name=coedit
StartupNotify=true
Terminal=false
Type=Application" > $shcdir/coedit.desktop

cd $HOME/rpmbuild/SPECS
echo "Name: coedit
Version: $maj.$min.$pch
Release: $lbl
Summary: IDE for the D programming language
License: Boost
URL: www.github.com/BBasile/Coedit
Requires: gtk2, glibc, cairo, libX11

%description
Coedit is an IDE for the DMD D compiler.

%files
/usr/bin/dastworx
/usr/bin/coedit
/usr/share/applications/coedit.desktop
/usr/share/pixmaps/coedit.png

%changelog
* $dte Basile Burg b2.temp@gmx.com
- see https://github.com/BBasile/Coedit/releases/tag/$ver
">$specname

rpmbuild -ba $specname
