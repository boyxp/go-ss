#!/bin/bash
#安装wget
if command -v wget >/dev/null 2>&1; then
        echo "wget已安装"
else
        echo "开始安装wget"
        yum install wget.x86_64
fi

#安装go
if command -v go >/dev/null 2>&1; then
        echo "golang已安装"
else
        echo "开始安装golang"
        wget https://go.dev/dl/go1.20.2.linux-amd64.tar.gz
        tar xvf go1.20.2.linux-amd64.tar.gz
        mv go /usr/local/
        ln -s /usr/local/go/bin/go /usr/bin/go
fi

if command -v go >/dev/null 2>&1; then
        echo "golang已安装成功"
else
        echo "golang安装失败"
        exit 1
fi

go install github.com/shadowsocks/shadowsocks-go/cmd/shadowsocks-server@latest

n=$(ls /root/go/pkg/mod/github.com/shadowsocks/)

path=/root/go/pkg/mod/github.com/shadowsocks/$n/cmd/shadowsocks-server/

echo $path

cd $path

echo "写入config"
port=$(date +1%m%d)
json="{\"server\":\"0.0.0.0\",\"server_port\":${port},\"local_port\":1080,\"local_address\":\"127.0.0.1\",\"password\":\"helloworld\",\"method\": \"aes-128-cfb\",\"timeout\":600}"
echo $json > config.json

echo "写入自动命令"
echo '#!/bin/bash
port=$(date +1%m%d)
json="{\"server\":\"0.0.0.0\",\"server_port\":${port},\"local_port\":1080,\"local_address\":\"127.0.0.1\",\"password\":\"helloworld\",\"method\": \"aes-128-cfb\",\"timeout\":600}"
echo $json > config.json
' > auto.sh
echo "ps aux | grep server | grep go | awk '{print \$2}' | xargs kill
go run server.go -c config.json > run.log &
" >> auto.sh

#写入定时任务
ck=$(crontab -l | grep shadow | wc -l)
if [ $ck -eq "0" ]; then
    echo "10 00 * * * cd $path && sh auto.sh" > /var/spool/cron/root
fi

go mod init ss.com

#首次启动
nohup go run server.go -c config.json > run.log 2>&1 &

