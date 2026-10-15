#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

while getopts "ha:p:u:n:rs" opt; do
  case $opt in
  h)
    echo "Usage: rebuild.sh -a ip-address -n hostname [-h] [-p port] [-u user] [-r]"
    echo "  -a  target IP address (required)"
    echo "  -n  hostname to rebuild (required)"
    echo "  -p  SSH port (default 22)"
    echo "  -u  SSH user (default root)"
    echo "  -r  build on the remote host"
    echo "  -s  ask for sudo password"
    exit 0
    ;;
  a)
    IP_ADDRESS=$OPTARG
    ;;
  p)
    SSH_PORT=$OPTARG
    ;;
  u)
    SSH_USER=$OPTARG
    ;;
  n)
    HOST_NAME=$OPTARG
    ;;
  r)
    REMOTE_BUILD="remote"
    ;;
  s)
    ASK_SUDO="yes"
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  esac
done

if [ -z "${IP_ADDRESS:-}" ]; then
  echo "No IP-Address provided" >&2
  exit 1
fi

if [ -z "${HOST_NAME:-}" ]; then
  echo "No host to rebuild provided" >&2
  exit 1
fi

SSH_PORT=${SSH_PORT:-22}
SSH_USER=${SSH_USER:-"root"}
REMOTE_BUILD=${REMOTE_BUILD:-"local"}
ASK_SUDO=${ASK_SUDO:-"no"}

TARGET="$SSH_USER@$IP_ADDRESS"

args=(
  switch
  --flake ".#$HOST_NAME"
  --target-host "$TARGET"
)

# Build on the target instead of locally
if [ "$REMOTE_BUILD" = "remote" ]; then
  args+=(--build-host "$TARGET")
fi

# Non-root users need sudo on the remote side
if [ "$SSH_USER" != "root" ]; then
  args+=(--sudo)
  if [ "$ASK_SUDO" = "yes" ]; then
    args+=(--ask-sudo-password)
  fi
fi

export NIX_SSHOPTS="-p $SSH_PORT"

nix run nixpkgs#nixos-rebuild -- "${args[@]}"
