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
