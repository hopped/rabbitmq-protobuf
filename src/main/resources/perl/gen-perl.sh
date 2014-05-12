#!/bin/bash

echo Generating Perl library for the RabbitMQ/Protobuf example
echo Use 'tail -f build.log' to monitor progress.

(
    CURDIR=`pwd`
    PREFIX=`pwd`/gen-perl
    PROTO=SimpleRunner
    PROTO_EXT=proto

( # cleanup for further processing
    cd /tmp
    if [ -d ${PREFIX} ]
    then
        rm -rf ${PREFIX}
    fi
    mkdir ${PREFIX}
)

( # copy relevant files to /tmp

    if [ -d /tmp/${PROTO} ]
    then
        rm -rf /tmp/${PROTO}
    fi
    mkdir /tmp/${PROTO}

    cd /tmp/${PROTO}

    cp ${CURDIR}/../${PROTO}.${PROTO_EXT} .
    cp ${CURDIR}/${PROTO}.* .
    cp ${CURDIR}/Makefile.PL .
)

( # run
    cd /tmp/${PROTO}

    mkdir target
    perl Makefile.PL
    make
)

( # finish
    cd /tmp/${PROTO}

    mv blib ${PREFIX}
)


) >build.log 2>&1
echo Done!
