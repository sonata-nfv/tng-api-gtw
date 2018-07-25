# [SONATA](http://www.sonata-nfv.eu)'s Gatekeeper API micro-service
[![Build Status](http://jenkins.sonata-nfv.eu/buildStatus/icon?job=son-gkeeper)](http://jenkins.sonata-nfv.eu/job/son-gkeeper)

This folder has the configuration, code and specifications of sonata security gateway.

## Architecture
The tng-sec-gtw will enable a security layer for SONATA (powered by 5GTANGO) Verification&Validation and Service Platforms components. To be used as a part of infrastructure the following was considered:
* Is a nginx proxy-pass container;
* Is located in front of tng-router and tng-portal;
* Certificates should be mounted as a volume inside the tng-sec-gtw;
* Communication between tng-sec-gtw and other internal components is always in https;
* Communication between clients and tng-sec-gtw is in https if certificates exists, otherwise http is allowed but with a warning.

```

              +----------------+                +---------------+
     https    |                |     http       |               |
   +---------^+  tng-sec-gtw   +---------------->  tng-router   |
              |                |        |       |               |
              +----------------+        |       +---------------+
                                        |
                                        |       +---------------+
                                        |       |               |
                                        +------->   tng-portal  |
                                                |               |
                                                +---------------+
```

## Usage
To use this module you can do it by this way:

```shell
$ docker network create tango
$ docker run -d -p 80:80 --net=tango --name tng-portal sonatanfv/tng-portal:4.0
$ docker run -d -p 5000:5000 --net=tango --name tng-router sonatanfv/tng-router:4.0
$ docker run -d -p 80:80 -p 443:443 -v /etc/ssl/private/sonata/:/etc/nginx/cert/ --net=tango --name tng-sec-gtw \
  -e ROUTES_FILE=sp_routes.yml \
  sonatanfv/tng-sec-gtw:4.0
```
With these commands, you:

1. Create a `docker` network named `tango`;
1. Run the [Portal](https://github.com/sonata-nfv/tng-portal) container within the `tango` network;
1. Run the [Router](https://github.com/sonata-nfv/tng-sec-gtw/tree/master/tng-router) container within the `tango` network;
1. Run the [Security Gateway](https://github.com/sonata-nfv/tng-api-gtw/tree/master/tng-sec-gtw) container within the `tango` network.

OPTIONS:
* `--name`: Container name (Optional)
* `--net`: Network name
* `-p`:
    * 80:80 External port 80 -> Internal port 80
    * 443:443 External port 443 -> Internal port 443.
* `-v`: certificates have to be located in the folder /etc/nginx/cert with the names `CERT=sonata.cert` and `KEY=sonata.key`.
* `ROUTES_FILE`: name of the router's configuration file (defaults to `sp_routes.yml`)
