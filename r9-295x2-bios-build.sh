#!/bin/bash

projectdir=$(realpath $(dirname "$0"))
builddir=$projectdir/build/r9-295x2
distdir=$projectdir/dist

primary_name="r9-295x2-primary.rom"
primary_bios="168806"
primary_sha1="5548cee932e1bc2e59df5b478af08cd20d7a2845"
secondary_name="r9-295x2-secondary.rom"
secondary_bios="160959"
secondary_sha1="802f119c1e296f4501b802a120fd70530a1f3d41"

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

vgabios() {
    local bios=$1
    local filename=$2
    echo "Downloading ${bios} from TechPowerUp..."
    wget -q "https://www.techpowerup.com/vgabios/${bios}/${bios}.rom" -O "${filename}"
}


set -e
mkdir -p $builddir $distdir
cd $builddir

if ! $(shatest "$distdir/$primary_name" $primary_sha1 )
then
    echo "R9 295X2 primary BIOS missing!"
    vgabios $primary_bios $primary_name
    if $(shatest "$primary_name" $primary_sha1 )
    then
        echo "Primary BIOS valid, moving to $distdir..."
        mv $primary_name $distdir/
    else
        echo "Primary BIOS invalid!"
        exit 1
    fi
else
    echo "R9 295X2 primary BIOS up to date, skipping..."
fi

if ! $(shatest "$distdir/$secondary_name" $secondary_sha1 )
then
    echo "R9 295X2 secondary BIOS missing!"
    vgabios $secondary_bios $secondary_name
    if $(shatest "$secondary_name" $secondary_sha1 )
    then
        echo "Secondary BIOS valid, moving to $distdir..."
        mv $secondary_name $distdir/
    else
        echo "Secondary BIOS invalid!"
        exit 1
    fi
else
    echo "R9 295X2 secondary BIOS up to date, skipping..."
fi
