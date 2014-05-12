#!/bin/bash

echo Generating Java classes for the RabbitMQ/Protobuf example
echo Use 'tail -f build.log' to monitor progress.

(
    CURDIR=`pwd`
    PREFIX=`pwd`/gen-java
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
)

( # run
    cd /tmp/${PROTO}

    mkdir ${PREFIX}
    protoc --java_out=${PREFIX} ${PROTO}.${PROTO_EXT}
)

( # finish
    cd /tmp/${PROTO}

    mv ${PREFIX} ${CURDIR}/${PREFIX}
)

) >build.log 2>&1
echo Done!
