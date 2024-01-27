#!/bin/bash

github=https://github.com/
raw=https://raw.githubusercontent.com/

curl() {
    # Copy from https://github.com/XTLS/Xray-install
    if ! $(type -P curl) -L -q --retry 5 --retry-delay 10 --retry-max-time 60 "$@";then
        echo "ERROR:Curl Failed, check your network"
        exit 1
    fi
}

case $(lscpu) in
    *avx512*)
        microArch=4
        ;;
    *avx2*)
        microArch=3
        ;;
    *sse4_2*)
        microArch=2
        ;;
    *)
        microArch=1
        ;;
esac

groupadd --system sing-box
useradd --system --gid sing-box --create-home --home-dir /var/lib/sing-box --shell /usr/sbin/nologin sing-box

curl -o /usr/local/bin/sing-box $github/AsenHu/sing-box/releases/download/with_quic/sing-box-linux-amd64-v$microArch
# curl -o /etc/systemd/system/sing-box.service $raw/AsenHu//master/init/sing-box.service