#!/usr/bin/env bash

set -eux

# From the relevant SHASUMS256.txt file at:
# https://github.com/jcheng5/node-centos6/releases
# The node-v{VERSION}-linux-x64.tar.xz checksum is the one we need.

cd $(dirname $0)
cd ../..

NODE_VERSION=$(cat .nvmrc)

check_node_needed () {
  if [ -x ext/node/bin/node ]
  then
    local CURRENT_NODE_VERSION=$(ext/node/bin/node --version 2>/dev/null)
    if [[ "$CURRENT_NODE_VERSION" == "$NODE_VERSION" ]]
    then
      echo "Node $NODE_VERSION is already installed, skipping" >&2
      exit 0
    fi
  fi
}

verify_checksum () {
  local FILE=$1
  local EXPECTED_CHECKSUM=$2

  local ACTUAL_CHECKSUM=$(sha256sum "$FILE")
  [[ "$EXPECTED_CHECKSUM  $FILE" != "$ACTUAL_CHECKSUM" ]]
}

download_node () {
  case $(uname -m) in
  s390x ) export archt=s390x && export NODE_SHA256=5f9b580fc0d9cb412c0482ede23de2c68063942fecd44565cc0e509ed06b4d02
  ;;
  x86_64 ) export archt=x64 && export NODE_SHA256=80fc80cdb3d829ea4d752c2e52067a426f6c4fd629ecca5a858d268af8d5ec7e
  ;;
  ppc64le ) export archt=ppc64le
  ;;
  esac
  local NODE_FILENAME="node-${NODE_VERSION}-linux-${archt}.tar.xz"
  local NODE_URL="https://nodejs.org/dist/${NODE_VERSION}/${NODE_FILENAME}"
  local NODE_ARCHIVE_DEST="/tmp/${NODE_FILENAME}"
  echo "Downloading Node ${NODE_VERSION} from ${NODE_URL}"

  wget -O "$NODE_ARCHIVE_DEST" "$NODE_URL"
  if verify_checksum "$NODE_ARCHIVE_DEST" "$NODE_SHA256"
  then
    echo "Checksum failed!" >&2
    exit 1
  fi

  rm -rf ext/node
  mkdir -p ext/node
  echo "Extracting ${NODE_FILENAME}"
  tar xf "${NODE_ARCHIVE_DEST}" --strip-components=1 -C "ext/node"

  # Clean up temp file
  rm "${NODE_ARCHIVE_DEST}"

  cp ext/node/bin/node ext/node/bin/shiny-server
  rm ext/node/bin/npm
  (cd ext/node/lib/node_modules/npm && ./scripts/relocate.sh)
}

check_node_needed
download_node
