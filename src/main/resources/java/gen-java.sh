#!/bin/bash

echo Generating Java classes for the RabbitMQ/Protobuf example
echo Use 'tail -f build.log' to monitor progress.

(
    CURDIR=`pwd`
    PREFIX=`pwd`/gen-java
    PROTO=SimpleRunner
    PROTO_EXT=proto

( # cleanup for further processing
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
)

( # run
    cd /tmp/${PROTO}

    protoc --java_out=${PREFIX} ${PROTO}.${PROTO_EXT}
)

( # finish
    cd ${PREFIX}

    cp -r * ${CURDIR}/../../java
)

) >build.log 2>&1
echo Done!
