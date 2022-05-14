#!/bin/bash

# check if host name variable is set and change the name if it is set
if [[ ! -z "${SYSBOX_HOST}" ]] && [[ "$SYSBOX_HOST" != "$HOSTNAME" ]]; then

  if [[ "$SYSBOX_HOST" == *"_"* ]]; then
    echo "The hostname is not allowed to contain underscores. The set hostname is '$SYSBOX_HOST'."
    exit 1
  fi

  echo "Setting hostname to '$SYSBOX_HOST'."
  sudo echo "$SYSBOX_HOST" > /etc/hostname
  echo $(hostname -I | cut -d\  -f1) $SYSBOX_HOST | sudo tee -a /etc/hosts
  echo 127.0.0.1 $SYSBOX_HOST | sudo tee -a /etc/hosts
  echo 127.0.1.1 $SYSBOX_HOST.example.com $SYSBOX_HOST >> /etc/hosts
fi

# check if admin password variable is set and change the name if it is set
if [[ ! -z "${SYSBOX_PASSWORD}" ]]; then
  echo "Password environment variable found. Changing password for user admin."
  sudo usermod --password $(echo $SYSBOX_PASSWORD | openssl passwd -1 -stdin) admin
fi

# check if certificates are present and add them to the system if they are set
if [ -d "/sysbox/certificate" ] ; then
  echo "Found a ssh certificate."

  if [ -d "/sysbox/cert_added" ]; then
    echo "Certificate was already added."
  else
    sudo mkdir /sysbox/cert_added
    sudo cp /sysbox/certificate/* /sysbox/cert_added/

    sudo chmod 777 /sysbox/cert_added -Rf

    echo 'eval $(keychain -q --eval /sysbox/cert_added/cert.private)' >> /home/admin/.bashrc

    echo "Added certificate to system."
  fi
fi


# start the comandline
exec /sbin/init --log-level=info
