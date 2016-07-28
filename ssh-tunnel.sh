#!/bin/bash

function log {
  echo "ssh-tunnel	event=$1"
}

function is_configured {
  [[ \
    -v SSHTUNNEL_PRIVATE_KEY && \
    -v SSHTUNNEL_TUNNEL_CONFIG && \
    -v SSHTUNNEL_REMOTE_USER && \
    -v SSHTUNNEL_REMOTE_HOST
  ]] && return 0 || return 1
}

function deploy_key {
  mkdir -p ${HOME}/.ssh
  chmod 700 ${HOME}/.ssh

  echo "${SSHTUNNEL_PRIVATE_KEY}" > ${HOME}/.ssh/ssh-tunnel-key
  chmod 600 ${HOME}/.ssh/ssh-tunnel-key

  ssh-keyscan ${SSHTUNNEL_REMOTE_HOST} > ${HOME}/.ssh/known_hosts
}

function spawn_tunnel {
  while true; do
    log "ssh-connection-init"
    ssh -i ${HOME}/.ssh/ssh-tunnel-key -N -o "ServerAliveInterval 10" -o "ServerAliveCountMax 3" -o "ConnectTimeout 10" -L ${SSHTUNNEL_TUNNEL_CONFIG} ${SSHTUNNEL_REMOTE_USER}@${SSHTUNNEL_REMOTE_HOST} -p ${SSHTUNNEL_REMOTE_PORT}
    log "ssh-connection-end"
    sleep 5;
  done &
}

log "starting"

if is_configured; then
  [ -v SSHTUNNEL_REMOTE_PORT ] || SSHTUNNEL_REMOTE_PORT=22

  deploy_key
  spawn_tunnel

  log "spawned";
else
  log "missing-configuration"
fi
