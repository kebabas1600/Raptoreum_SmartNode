#!/bin/bash

COIN_NAME='neoxa'
COIN_DAEMON='neoxad'
COIN_CLI='neoxa-cli'
#COIN_TX='raptoreum-tx'
COIN_PATH='/usr/local/bin'
WALLET_TAR=$(curl -s https://api.github.com/repos/NeoxaChain/Neoxa/releases/latest | jq -r '.assets[] | select(.name|test("linux64.")) | .browser_download_url')

# fetch latest release using github api
if pgrep $COIN_DAEMON; then
  $COIN_CLI stop
  mkdir temp
  curl -L $WALLET_TAR | tar xz -C ./temp; mv ./temp/$COIN_DAEMON ./temp/$COIN_CLI $COIN_PATH
  $COIN_DAEMON
else
  mkdir temp
  curl -L $WALLET_TAR | tar xz -C ./temp; mv ./temp/$COIN_DAEMON ./temp/$COIN_CLI $COIN_PATH
  rm -rf temp
fi
 
