#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

while getopts "ha:p:u:n:r" opt; do
  case $opt in
  h)
    echo "Usage: deploy.sh -a ip-address -n hostname [-h] [-p port] [-u user] [-r]"
    echo "  -a  target IP address (required)"
    echo "  -n  hostname to deploy (required)"
    echo "  -p  SSH port (default 22)"
    echo "  -u  SSH user (default nixos)"
    echo "  -r  build on the remote host"
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
  echo "No host to deploy provided" >&2
  exit 1
fi

SSH_PORT=${SSH_PORT:-22}
SSH_USER=${SSH_USER:-"nixos"}
REMOTE_BUILD=${REMOTE_BUILD:-"local"}

# read -rsp "SSH Password: " SSHPASS
# echo

# Create a temporary directory
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

# Create the directory where sshd expects to find the host keys
install -d -m755 "$temp/etc/ssh"

# Generate a new host key and store it in the temporary directory
ssh-keygen \
  -t ed25519 \
  -a 100 \
  -C "$HOST_NAME" \
  -f "$temp/etc/ssh/ssh_host_ed25519_key" \
  -N ""

# Set the correct permissions so sshd will accept the key
chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

# ssh-copy-id -o StrictHostKeyChecking=no -f -p "$SSH_PORT" "$SSH_USER@$IP_ADDRESS"

shopt -s nullglob

AGE_KEY=$(nix run nixpkgs#ssh-to-age -- <"$temp/etc/ssh/ssh_host_ed25519_key.pub")
[[ "$AGE_KEY" == age1* ]] || {
  echo "ssh-to-age failed" >&2
  exit 1
}

sed -i.bak -E "s|^([[:space:]]*- &${HOST_NAME} )[^[:space:]]+|\1${AGE_KEY}|" .sops.yaml
rm -f .sops.yaml.bak
grep -qE "^[[:space:]]*- &${HOST_NAME} ${AGE_KEY}\$" .sops.yaml ||
  {
    echo "anchor &${HOST_NAME} not found in .sops.yaml" >&2
    exit 1
  }

for f in secrets/*.yaml; do sops updatekeys -y "$f"; done

touch "./hardware-configuration/$HOST_NAME.json"
git add "./hardware-configuration/$HOST_NAME.json"

# export SSHPASS
nix run github:nix-community/nixos-anywhere -- \
  --flake ".#$HOST_NAME" \
  --target-host "$SSH_USER@$IP_ADDRESS" \
  --ssh-port "$SSH_PORT" \
  --generate-hardware-config nixos-facter "./hardware-configuration/$HOST_NAME.json" \
  --extra-files "$temp" \
  --build-on "$REMOTE_BUILD" # --env-password \
