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

groupadd --system caddy
useradd --system --gid caddy --create-home --home-dir /var/lib/caddy --shell /usr/sbin/nologin --comment "Caddy web server" caddy

curl -o /usr/bin/caddy $github/AsenHu/caddy-builder/releases/download/cfdnstls/caddy-linux-amd64-v$microArch
curl -o /etc/systemd/system/caddy.service $raw/caddyserver/dist/master/init/caddy.service

chmod +x /usr/bin/caddy

mkdir -p /etc/caddy
if [ ! -f /etc/caddy/Caddyfile ]
then
    echo -e ':2077\nrespond "Hello, world!"' > /etc/caddy/Caddyfile
fi
if ! /usr/bin/caddy validate --config /etc/caddy/Caddyfile
then
    mv -b /etc/caddy/Caddyfile /etc/caddy/Caddyfile.badconfig
    echo -e ':2077\nrespond "Hello, world!"' > /etc/caddy/Caddyfile
fi

systemctl daemon-reload
systemctl enable caddy
systemctl restart caddy