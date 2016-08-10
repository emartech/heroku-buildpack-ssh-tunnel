# Heroku buildpack: ssh-tunnel

This heroku buildpack makes it possible for an application to establish ssh tunnel to reach a remote host.
This buildpack must be used with a language-specific buildpack as a supplement.


## Usage

1. Add this buildpack before your language-specific buildpacks:

```console
$ heroku buildpacks:set https://github.com/szeist/heroku-buildpack-ssh-tunnel
```

2. Add your language-specific buildpack (nodejs in this case):

```console
$ heroku buildpacks:set heroku/nodejs
```

## Configuration

### Static configuration

| Configuration | Value |
| ------------- | ----- |
| openssh connect timeout | 10 sec |
| keepalive interval | 10 sec |
| maximum number of keepalives | 3 |
| reconnect after | 5 sec |

The buildpack creates an ssh tunnel on the basis of the environment variables configured for Heroku:

- ``SSHTUNNEL_PRIVATE_KEY``: Private key for connecting to the tunnel host
- ``SSHTUNNEL_TUNNEL_CONFIG``: Tunnel configuration (openssh -L syntax) ``[LOCAL PORT]:[REMOTE_HOST]:[REMOTE_PORT]``
- ``SSHTUNNEL_REMOTE_USER``: Username for connecting to the tunnel server
- ``SHTUNNEL_REMOTE_HOST``: The tunnel server hostname
- ``SSHTUNNEL_REMOTE_PORT``: (optional) Port for connecting the tunnel server. Default is 22.

## Logging

The buildpack logs to the standard output with the 'ssh-tunnel' prefix.

### Logged events:

| Event | Description |
| ----- | ----------- |
| starting | logged on dyno start | 
| spawned | logged after "tunnel-daemon" starts | 
| missing-configuration | logged on any missing configuration (tunnel-daemon is not started as variables are not defined properly) | 
| ssh-connection-init | logged before initiating ssh connection | 
| ssh-connection-end | logged after the ssh connection ends or there is a connection error | 

