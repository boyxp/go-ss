#!/bin/bash
#安装golang
if command -v go version >/dev/null 2>&1; then
    echo "golang已安装"
else
    echo "开始安装golang"
    yum install golang-bin.x86_64
fi
#安装ss
echo "开始安装ss"
go get github.com/shadowsocks/shadowsocks-go/cmd/shadowsocks-server

cd /root/go/src/github.com/shadowsocks/shadowsocks-go/cmd/shadowsocks-server/

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
    echo "10 00 * * * cd /root/go/src/github.com/shadowsocks/shadowsocks-go/cmd/shadowsocks-server/ && sh auto.sh" > /var/spool/cron/root
fi

#首次启动
nohup go run server.go -c config.json > run.log 2>&1 &
