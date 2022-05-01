# Setup transparent proxy on debian based system
```shell
$ vi config.sh
$ sudo ./bootstrap.sh
```

# Example of running v2ray container:

```shell
$ # prepare directory
$ mkdir foo
$ wd=`pwd`
$ mkdir foo/conf
$ mkdir foo/data
$ # prepare config file
$ cp ..../v2ray.config.server foo/conf/config.json
$ # prepare v2ray data
$ cd foo
$ cat <<EOT > update_v2ray_data.sh
curl -L -q --retry 5 --retry-delay 10 --retry-max-time 60 -x socks5://localhost:1080 -o ${wd}/data/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat
curl -L -q --retry 5 --retry-delay 10 --retry-max-time 60 -x socks5://localhost:1080 -o ${wd}/data/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat
echo "Executed @ `date`" >> ${wd}/data/update.log
echo ""

echo "Run proxy service: ======================="
echo "docker service create --name v2ray-client-at-1080 --mount type=bind,source=${wd}/conf,target=/etc/v2ray --mount type=bind,source=${wd}/data,target=/usr/local/share/v2ray/,readonly --publish 1080:10086 v2fly/v2fly-core"
echo ""

echo "Stop proxy service: ======================"
echo "docker service rm v2ray-client-at-1080"
echo ""

echo "Add crontab daily task: ======================"
echo "With command: crontab -e"
echo "With line content: \"0 0 * * * ${wd}/update_v2ray_data.sh\""

EOT

$ # run update script (and the script will print docker service command)
$ . ./update_v2ray_data.sh
$ # run proxy as docker service (with the)
$ docker service create --name v2ray-client-at-1080 --mount type=bind,source=/<full-path>/foo/conf,target=/etc/v2ray --mount type=bind,source=/<full-path>/foo/data,target=/usr/local/share/v2ray/,readonly --publish 1080:10086 v2fly/v2fly-core
$ # stop the service
$ docker service rm v2ray-client-at-1080
```


https://hub.docker.com/r/v2fly/v2fly-core
https://github.com/v2fly/docker