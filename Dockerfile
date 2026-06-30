FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    git \
    vim \
    nano \
    unzip \
    zip \
    htop \
    net-tools \
    iproute2 \
    iputils-ping \
    dnsutils \
    bash-completion \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd

RUN mkdir -p /root/.ssh
COPY authorized_keys /root/.ssh/authorized_keys
RUN chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys

COPY utils/apt.sh /root/bin/apt.sh
RUN chmod +x /root/bin/apt.sh

ENV PATH="/root/bin:${PATH}"

RUN echo "PermitRootLogin prohibit-password" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd","-D","-e"]
