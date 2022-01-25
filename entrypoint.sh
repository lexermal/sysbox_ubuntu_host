#!/bin/bash

# check if host name variable is set and change the name if it is set
if [[ ! -z "${SYSBOX_HOST}" ]] && [[ "$SYSBOX_HOST" != "$HOSTNAME" ]]; then
  echo "Setting hostname to '$SYSBOX_HOST'."
  sudo echo "$SYSBOX_HOST" > /etc/hostname
  echo $(hostname -I | cut -d\  -f1) $SYSBOX_HOST | sudo tee -a /etc/hosts
fi

# check if admin password variable is set and change the name if it is set
if [[ ! -z "${SYSBOX_PASSWORD}" ]]; then
  echo "Password environment variable found. Changing password for user admin."
  sudo usermod --password $(echo $SYSBOX_PASSWORD | openssl passwd -1 -stdin) admin
fi

# check if certificates are present and add them to the system if they are set
if [ -d "/sysbox/certificate" ] ; then
  echo "Found a ssh certificate."

  FILE=/sysbox/cert_added
  if [ -f "$FILE" ]; then
    echo "Certificate was already added."
  else
    sudo chmod 600 /sysbox/certificate/cert.private
    echo 'eval $(keychain -q --eval /sysbox/certificate/cert.private)' >> /home/admin/.bashrc
    touch /sysbox/cert_added
    echo "Added certificate to system."
  fi
fi


# start the comandline
exec /sbin/init --log-level=err
