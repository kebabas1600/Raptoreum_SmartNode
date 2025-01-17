#!/bin/bash

EXECUTABLE='neoxad'
DIR='/neoxa/.neoxacore'
CONF_FILE='neoxa.conf'
FILE=$DIR/$CONF_FILE


# Create directory and config file if it does not exist yet
if [ ! -e "$FILE" ]; then
  mkdir -p $DIR
  if [ -n "$BLS_KEY" ]; then
    cat << EOF > $FILE
rpcuser=$(pwgen -1 8 -n)
rpcpassword=$(pwgen -1 20 -n)
rpcallowip=127.0.0.1
rpcbind=127.0.0.1
txindex=1
listen=1
par=2
dbcache=1024
smartnodeblsprivkey=${BLS_KEY}
externalip=${EXTERNALIP}
EOF
  else
    cat << EOF > $FILE
rpcuser=$(pwgen -1 8 -n)
rpcpassword=$(pwgen -1 20 -n)
rpcallowip=127.0.0.1
rpcbind=127.0.0.1
server=1
listen=1
EOF
  fi
fi

# Setup logrotate for debug log
touch /etc/logrotate.d/neoxadebuglog
cat << EOF > /etc/logrotate.d/neoxadebuglog
/neoxa/.neoxacore/debug.log {
  compress
  copytruncate
  missingok
  daily
  rotate 7
}
EOF

# Create script for HEALTHCHECK
if [ ! -e /usr/local/bin/healthcheck.sh ]; then
  touch healthcheck.sh
  cat << EOF > healthcheck.sh
#!/bin/bash

POSE_SCORE=\$(curl -s "https://explorer.neoxa.net/api/protx?command=info&protxhash=${PROTX_HASH}" | jq -r '.state.PoSePenalty')
if ((POSE_SCORE>0)); then
  kill -15 -1
  sleep 15
  kill -9 -1
else
  echo "Smartnode seems to be healthy..."
fi
EOF
  chmod 755 healthcheck.sh
  mv healthcheck.sh /usr/local/bin
fi

exec $EXECUTABLE -datadir=$DIR -conf=$FILE
