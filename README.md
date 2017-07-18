# Docker setup for PHP 7.1 and Apache 2.4

This is the basic setup for a docker box which contains both PHP 7.1 (FPM) and Apache 2.4 (Event MPM).

It returns both Access and Error logs via Stdout / Stderr, which can be accessed via `docker logs -f test_box`. This is so these can be easily push into CloudWatch.

It starts on port `180` but it's advisable to change this, so you can run multiple containers in your development environment.

## Instructions

Run the following command to start the box up:

```bash
docker-compose up -d --build
```

To log into the box for testing / debugging:

```bash
docker exec -it test_box bash
```

To shut down and remove the box:

```bash
docker-compose down
```

## Extending this container

This container ships with some basic supervisor.d and vhost rules.

To replace them with files of your choice, you can do the following:

```dockerfile
FROM    dittto/php71-apache24

COPY    etc/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY    etc/apache/default.conf /etc/apache2/sites-enabled/000-default.conf
```

This allows you change the vhost for whatever you need, or, like the example below, add extra programs to supervisord:

```
[supervisord]
nodaemon=true

[program:apache2]
command=/bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"

[program:php-fpm7.1]
command=/bin/bash -c "exec /usr/sbin/php-fpm7.1 -F"

[program:hi-there]
command=/bin/bash -c "echo hi there >> /var/docker_stdout"
autorestart=false
startsecs=0
exitcodes=0,1,2
```

This adds a single-use program called hi-there, which simply adds something to the output logs.