#!/bin/bash

set -eux

srcDir=${GOPATH}/src/$(basename ${SRC_PKG})

trap "rm -rf ${srcDir}" EXIT

# http://ask.xmodulo.com/compare-two-version-numbers.html
version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; }

if [ -d ${SRC_PKG} ]
then
    echo "Building in directory ${srcDir}"
    ln -sf ${SRC_PKG} ${srcDir}
elif [ -f ${SRC_PKG} ]
then
    echo "Building file ${SRC_PKG} in ${srcDir}"
    mkdir -p ${srcDir}
    cp ${SRC_PKG} ${srcDir}/function.go
fi

cd ${srcDir}

if [ -f "go.mod" ]; then
    if [ ! -z ${GOLANG_VERSION} ] && version_ge ${GOLANG_VERSION} "1.12"; then
        go mod download
    else
        echo "Please update fission/go-builder and fission/go-env image to the latest version to support go module"
        exit 1
    fi
else
    # still need to do this; otherwise, go will complain "cannot find main module".
    go mod init
fi

go build -buildmode=plugin -i -o ${DEPLOY_PKG} .
