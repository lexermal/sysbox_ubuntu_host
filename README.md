# Sysbox Ubuntu Host
This docker images allows to run docker totally secure inside a docker container using SYSBOX.

Inside the container all operations can be done like on a VM that has docker installed.
For persisting data from Sysbox_Ubuntu_Host's container it's recommended to mount a folder.

The image is based on Ubuntu 20.04 TLS.

## Quick links
* Github repo: https://github.com/lexermal/sysbox_ubuntu_host
* Dockerhub: https://hub.docker.com/r/mw685/sysbox_ubuntu_host

## Preconditions
The container can only be executed if SYSBOX is installed!

## Building the image
``docker build . -t mw685/sysbox_ubuntu_host:0.4.0 -t mw685/sysbox_ubuntu_host:latest``

## Pushing the image
``docker push mw685/sysbox_ubuntu_host:0.4.0 && docker push mw685/sysbox_ubuntu_host:latest``

## Running the image

### Minimal example
```
docker run --runtime=sysbox-runc -d -p 222:22 mw685/sysbox_ubuntu_host
```

This starts the container and opens ssh on localhost with port 222.
Simply connect with ``ssh admin@localhost -p 222``. The password is ``admin``.

### Full example
```
docker run --runtime=sysbox-runc -d -e SYSBOX_HOST=my_sysbox_host -e SYSBOX_PASSWORD=my_password -v /path/to/private/cert/cert.private:/sysbox/certificate/cert.private -v /path/to/public/cert/cert.pub:/sysbox/certificate/cert.pub -p 222:22 mw685/sysbox_ubuntu_host
```

This command executes the image with the changed hostname, password and imported ssh certificates.
The certificates get the permissions 0600 from the container.

Simply connect with ``ssh admin@localhost -p 222``. The password is ``my_password``.

To run a docker image inside Sysbox_Ubuntu_Host run the known commands from docker, eg. ``docker run hello-world``

### Docker-Compose example
A version of docker-compose greater then ``v2.2.2`` needs to be installed.

```
version: '3.3'
services:
    sysbox_ubuntu_host:
        image: mw685/sysbox_ubuntu_host
        userns_mode: sysbox
        runtime: sysbox-runc
        container_name: sysbox_ubuntu_host_1
        environment:
            - SYSBOX_HOST=sysbox_ubuntu_host_1
            - SYSBOX_PASSWORD=my_password
        volumes:
            - /path/to/private/cert/cert.private:/sysbox/certificate/cert.private
            - /path/to/public/cert/cert.pub:/sysbox/certificate/cert.pub
            - /host/path/where/data/of/container/gets/saved:/mnt/mydata/
        ports:
            - 222:22
        restart: always
```

## Configuration options

### Changing the hostname
In order to set the hostname simple use the environment variable ``SYSBOX_HOST``.

### Changing the password
The images comes with an admin user that has the password ``àdmin``.
To change this password simply use the environment variable ``SYSBOX_PASSWORD``.

### Setting up ssh certificates
For using the images for pulling private git repos from Gitlab or Github it's useful to set SSH certificates.
This is possible with mounting a ``cert.pub`` and ``cert.private`` into ``/sysbox/certificate``.
