#!/bin/bash

set -e
set -x

source ./constraint.sh
if ! [ "${ID}" -ge "1000" ]; then
    echo "This script cannot run as root."
    exit
fi

source ./functions.sh

clean(){
    echo Cleaning.
    ${SYNC}

    # Cleanup source
    pumount ${SRC}

    # Cleanup destination
    rm -rf ${TEMP}
    rm -rf ${ZIPTEMP}
    pumount ${DST}

    exit
}

trap clean EXIT TERM INT

# De we have a source device
if [ ! -b ${DEV_SRC} ]; then
    echo "Source device (${DEV_SRC}) does not exists."
    exit
fi
# Find the partition names on the source device
DEV_PARTITIONS=`ls "${DEV_SRC}"* | grep "${DEV_SRC}[1-9][0-6]*" || true`
if [ -z "${DEV_PARTITIONS}" ]; then
    echo "${DEV_SRC} does not have any partitions."
    exit
fi

# Do we have a destination device
if [ ! -b "/dev/${DEV_DST}" ]; then
    echo "Destination device (/dev/${DEV_DST}) does not exists."
    exit
fi

# mount and prepare destination device
if ${MOUNT}|grep ${DST}; then
    ${PUMOUNT} ${DST} || true
fi

/sbin/mkfs.ntfs ${DEV_DST}

# Groom da kitteh!

PARTCOUNT=1
for partition in ${DEV_PARTITIONS}
do
    # Processing a partition
    echo "Processing partition: ${partition}"
    if /sbin/mkfs.ntfs ${partition}
    fi
    let PARTCOUNT=`expr $PARTCOUNT + 1`
done

# The cleanup is automatically done in the function clean called when
# the program quits
