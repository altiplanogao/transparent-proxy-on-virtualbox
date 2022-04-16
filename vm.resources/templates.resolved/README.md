Example of running v2ray container:


```shell
$ # prepare config file
$ cp ./v2ray.config.server /localpath/config.json
$ # run as docker service
$ docker service create --name v2ray-client-at-1081 --mount type=bind,source=/localpath,destination=/etc/v2ray --publish 1081:10086 v2fly/v2fly-core:v4.44.0
$ # stop the service
$ docker service rm v2ray-client-at-1080
```


https://hub.docker.com/r/v2fly/v2fly-core
https://github.com/v2fly/docker