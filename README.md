# nginx2root

<center>
<img src="https://raw.githubusercontent.com/0xcypher110/nginx2root_lab/refs/heads/main/assets/cover.png">
</center>

A local, Docker-based reproduction of CVE-2026-123007, an HTTP/2 flow-control
integer underflow in nginx that leads to remote code execution with the
worker process's privileges. Published nginx versions 1.9.5 through 1.31.8
are affected when HTTP/2 is enabled; this image builds nginx 1.31.8 from
source, on Alpine Linux, with TLS and HTTP/2 turned on, so the behavior can
be studied against a real, pinned, vulnerable build rather than a simulation.

The container also carries a second, classic misconfiguration: a root cron
job that runs a world-writable script every minute. That gives the lab a
full path from an unauthenticated network foothold (the nginx worker user)
to root, entirely on your own machine.

CVE-2026-123007 is public and already patched upstream (fixed in nginx
1.31.9 / 1.30.7). This lab exists to practice against a disclosed,
documented vulnerability, not to target anything running in production.

References: [JFrog Security Research](https://research.jfrog.com/post/nginx2shell-all-you-need-to-know-about-cve-2026-123007-and-cve-2026-123633/), [Wiz](https://www.wiz.io/blog/nginx-http2-rce-vulnerabilities), [Qualys](https://blog.qualys.com/product-tech/patch-management/2026/11/18/nginx2root-five-nginx-flaws-led-by-cve-2026-123007-how-to-find-mitigate-and-patch-now)

## Requirements

- Docker
- Docker Compose (optional, a plain `docker build` / `docker run` also works)
- Internet access during the build (nginx 1.31.8 is compiled from source,
  fetched from nginx.org)

## Build and run

Using Compose:

```
docker compose up --build
```

Or plain Docker:

```
docker build -t nginx2root .
docker run --rm -p 9991:9991 nginx2root
```

The site is then reachable at `https://localhost:9991`. The certificate is
self-signed, so your browser or client will warn about it; that is expected.

## Objective

Two flags are hidden in the container:

- `/home/user_flag.txt` — reachable once you have code execution as the
  nginx worker user.
- `/root/root_flag.txt` — reachable only as root.

The first step is the real CVE-2026-123007 foothold against the HTTPS
service on port 9991. The second step is a local privilege-escalation
misconfiguration inside the container; enumerate what is running with
elevated privileges once you have a shell.

## Scope

This image reproduces a real, disclosed, and already-patched vulnerability
for local, isolated practice only. Do not expose port 9991 to a public
network or the internet, and do not point any exploit at a target you do
not own or have explicit permission to test.

## Stopping and cleaning up

```
docker compose down
```

or, without Compose:

```
docker stop nginx2root
```
