#!/bin/bash

projectdir=$(realpath $(dirname "$0"))
srcdir=$projectdir/firmware/x99-DELUXE
builddir=$projectdir/build/x99-bios
distdir=$projectdir/dist

biosurl="https://dlcdnets.asus.com/pub/ASUS/mb/LGA2011/X99-DELUXE"
biosver="X99-DELUXE-ASUS-4101"
sha1orig="f43076140620fc30ca0b673e6a08f71e2edcdc8b"
sha1patch="8230df9dba324996590aaa61c262b6730623aa14"

shatest() {

    local file=$1
    local sum=$2
    if [ -f $file ]
    then
        local result="$(cat ${file} | sha1sum | head -c 40)"
        [[ $result == $sum ]]
        return
    else
        return 1
    fi
}

getbios() {
    echo "Downloading x99-DELUXE bios ${biosver}..."
    wget "${biosurl}/${biosver}.zip"
    unzip "${biosver}.zip"
    rm "${biosver}.zip"
    return $(shatest "${biosver}.CAP" $sha1orig)
}

patchbios() {
    local patchdir=${srcdir}/${biosver}

    cd $builddir
    echo "Patching BIOS with latest microcode and roms..."
    xdelta3 -d -s ${biosver}.CAP $patchdir/microcode-and-rom_patch.xdelta S1.CAP
    echo "Patching BIOS to unlock MSR 0xE2..."
    xdelta3 -d -s S1.CAP $patchdir/msr_patch.xdelta S2.CAP
    rm S1.CAP
    mv S2.CAP ${biosver}.patched.CAP
    return $(shatest "${biosver}.patched.CAP" $sha1patch)
}

build() {
    cd $builddir

    # Check original BIOS is intact
    if ! $(shatest "${biosver}.CAP" $sha1orig)
    then
        echo "Original BIOS missing or broken!"
        getbios
    else
        echo "Original BIOS is valid."
    fi

    # Build patched BIOS if needed
    if ! $(shatest "${biosver}.patched.CAP" $sha1patch)
    then
        echo "Patched BIOS missing or broken!"
        patchbios
    else
        echo "Patched BIOS is valid."
    fi

    echo "Copying patched BIOS to $distdir..."
    cp "${biosver}.patched.CAP" $distdir/X99D.CAP
}

set -e
mkdir -p $builddir $distdir
if [ ! -f $distdir/X99D.cap ]
then
    echo "Building custom BIOS for X99-DELUXE..."
    build
elif ! $(shatest "$distdir/X99D.cap" $sha1patch )
then
    echo "X99D.cap file broken or old, rebuilding..."
    build
else
    echo "X99D.cap up-to-date, skipping..."
fi
