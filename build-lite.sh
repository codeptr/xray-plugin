#!/bin/bash
sum="sha1sum"

if ! hash sha1sum 2>/dev/null; then
    if ! hash shasum 2>/dev/null; then
        echo "I can't see 'sha1sum' or 'shasum'"
        echo "Please install one of them!"
        exit
    fi
    sum="shasum"
fi

[[ -z $upx ]] && upx="echo pending"
if [[ $upx == "echo pending" ]] && hash upx 2>/dev/null; then
    upx="upx -9"
fi

VERSION=$(git describe --tags)
LDFLAGS="-X main.VERSION=$VERSION -s -w -buildid="

OSES=(linux windows)
ARCHS=(amd64)

mkdir bin

for os in ${OSES[@]}; do
    for arch in ${ARCHS[@]}; do
        suffix=""
        if [ "$os" == "windows" ]; then
            suffix=".exe"
        fi
        env CGO_ENABLED=0 GOOS=$os GOARCH=$arch go build -v -trimpath -ldflags "$LDFLAGS" -o xray-plugin_${os}_${arch}${suffix}
        $upx xray-plugin_${os}_${arch}${suffix} >/dev/null
        tar -zcf bin/xray-plugin-${os}-${arch}-$VERSION.tar.gz xray-plugin_${os}_${arch}${suffix}
        $sum bin/xray-plugin-${os}-${arch}-$VERSION.tar.gz
    done
done
