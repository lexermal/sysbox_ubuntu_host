FROM ubuntu:focal

# Systemd installation
RUN apt-get update &&                            \
    apt-get install -y --no-install-recommends   \
            systemd                              \
            systemd-sysv                         \
            libsystemd0                          \
            ca-certificates                      \
            dbus                                 \
            iptables                             \
            iproute2                             \
            kmod                                 \
            locales                              \
            uidmap                               \
            sudo                                 \
            nano                                 \
            git                                  \
            keychain                             \
            apt-utils                            \
            wget                                 \
            cron                                 \
            udev                                 \
            curl

# Prevents journald from reading kernel messages from /dev/kmsg
RUN echo "ReadKMsg=no" >> /etc/systemd/journald.conf

# Create default 'admin/admin' user
RUN useradd --create-home --shell /bin/bash admin && echo "admin:admin" | chpasswd && adduser admin sudo

# Fix install message "(Can't locate Term/ReadLine.pm in @INC"
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Docker install
RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

# Add user "admin" to the Docker group
RUN usermod -a -G docker admin

# Housekeeping
RUN apt-get clean -y &&                                               \
    rm -rf                                                            \
       /var/cache/debconf/*                                           \
       /var/lib/apt/lists/*                                           \
       /var/log/*                                                     \
       /tmp/*                                                         \
       /var/tmp/*                                                     \
       /usr/share/doc/*                                               \
       /usr/share/man/*                                               \
       /usr/share/local/*

# Sshd install
RUN apt-get update && apt-get install --no-install-recommends -y      \
            openssh-server &&                                         \
    mkdir /home/admin/.ssh &&                                         \
    chown admin:admin /home/admin/.ssh

# Install docker-compose
RUN curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose
RUN ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
RUN docker-compose -v

# Install docker-complose bash completion
RUN curl \
    -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
    -o /etc/bash_completion.d/docker-compose

    
# Prepare sysbox entry script
RUN mkdir /sysbox
COPY ./entrypoint.sh /sysbox
RUN chmod 777 /sysbox -R

WORKDIR /sysbox

EXPOSE 22

# Make use of stopsignal (instead of sigterm) to stop systemd containers.
STOPSIGNAL SIGRTMIN+3

# Set systemd as entrypoint.
ENTRYPOINT [ "/sysbox/entrypoint.sh" ]
