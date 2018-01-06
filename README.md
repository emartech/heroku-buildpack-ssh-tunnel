# Heroku buildpack: ssh-tunnel

This heroku buildpack makes it possible for an application to establish ssh tunnel to reach a remote host.
This buildpack must be used with a language-specific buildpack as a supplement.


## Usage

1. Add this buildpack as your initial buildpack. The `-i 1` flag makes sure this buildpack comes
_before_ your language specific buildpack.

  ```console
  $ heroku buildpacks:add -i 1 https://github.com/emartech/heroku-buildpack-ssh-tunnel#subprocess --app [app name]
  ```

  **Note**: Use the `subprocess` branch of this buildpack. The `master` branch only exists for backwards-compatibility.

2. Make sure your language specific buildpack is also set for your application. Probably there is no need to do
anything here, but check it like so:

  ```console
  $ heroku buildpacks --app [app name]
  === [app name] Buildpack URLs
  1. https://github.com/emartech/heroku-buildpack-ssh-tunnel#subprocess
  2. heroku/php
  ```

  If you do not see your language specific buildpack, add it (nodejs in this case):

  ```console
  $ heroku buildpacks:add heroku/nodejs --app [app name]
  ```

  Refer to the [buildpack documentation](https://devcenter.heroku.com/articles/using-multiple-buildpacks-for-an-app)
  for further help.

3. [Generate SSH key-pair](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/).
Do _not_ set a password for the key.

  ```console
  $ ssh-keygen -t rsa -b 4096 -C "[app name]@heroku.com"
  ```

  Distribute the **public** key to the remote party.

4. [Configure](#Configuration) the environment variables.

5. Edit your `Procfile`, so that the dynos that use SSH tunneling are started with the `bin/start-ssh-tunnel` command.
Prepend the actual starting command with this executable. If you do not have a `Procfile`, create one. For example:

  ```
  web: bin/start-ssh-tunnel vendor/bin/heroku-php-apache2 web/
  ```

  or

  ```
  web: bin/start-ssh-tunnel npm start
  ```

6. Update your connection strings (e.g. `REDIS_URL`) to go through the specified SSH tunnel. For example if the connection
string without SSH tunnel is

  ```
  REDIS_URL=redis://admin:[password]@aws-eu-west-1-portal.10.dblayer.com:18106
  ```

  and your tunnel configuration is like

  ```
  SSHTUNNEL_TUNNEL_CONFIG='127.0.0.1:6379 [REDIS_HA_PROXY_IP]:[REDIS_HA_PROXY_PORT]'
  ```

  then your connection string becomes

  ```
  REDIS_URL=redis://admin:[password]@127.0.0.1:6379
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
- ``SSHTUNNEL_TUNNEL_CONFIG``: Tunnel configuration (openssh -L syntax, note the space between the local and remote parts)
``[LOCAL_HOST]:[LOCAL PORT] [REMOTE_HOST]:[REMOTE_PORT]``
- ``SSHTUNNEL_REMOTE_USER``: Username for connecting to the tunnel server
- ``SSHTUNNEL_REMOTE_HOST``: The tunnel server hostname
- ``SSHTUNNEL_REMOTE_PORT``: (optional) Port for connecting the tunnel server. Default is 22.

## Notes / Caveats

- It takes time (although very little) to build the SSH tunnel. So there is a chance that your application might try
to connect to the remote party before the tunnel is built, in which case it is going to fail. If your library
automatically reconnects to the resource, then this is a non-issue. If it does not, however, you need to make sure
to retry or wait within your application.

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

## Use Case: SSH tunnel for Compose.io Redis

TBD

