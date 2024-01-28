#!/bin/bash

# 设置反向代理
github=https://github.com/
raw=https://raw.githubusercontent.com/

curl() {
    # Copy from https://github.com/XTLS/Xray-install
    if ! $(type -P curl) -L -q --retry 5 --retry-delay 10 --retry-max-time 60 "$@";then
        echo "ERROR:Curl Failed, check your network"
        exit 1
    fi
}

# 检测微架构
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

# 安装 sing-box
groupadd --system sing-box
useradd --system --gid sing-box --create-home --home-dir /var/lib/sing-box --shell /usr/sbin/nologin sing-box

curl -o /usr/local/bin/sing-box $github/AsenHu/sing-box/releases/download/with_quic/sing-box-linux-amd64-v$microArch
curl -o /etc/systemd/system/sing-box.service $raw/AsenHu/rootmust_script/main/systemd/sing-box.service

chmod +x /usr/local/bin/sing-box

# 配置 sing-box
mkdir -p /usr/local/etc/sing-box/
if [ ! -f /usr/local/etc/sing-box/config.json ]
then
    echo -e '{}' > /usr/local/etc/sing-box/config.json
fi
if ! /usr/local/bin/sing-box check --config /usr/local/etc/sing-box/config.json
then
    mv -b /usr/local/etc/sing-box/config.json /usr/local/etc/sing-box/config.json.bad
    echo -e '{}' > /usr/local/etc/sing-box/config.json
fi

# 启动 sing-box
systemctl daemon-reload
systemctl enable sing-box
systemctl restart sing-box
