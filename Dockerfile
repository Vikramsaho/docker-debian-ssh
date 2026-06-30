FROM debian:bookworm-slim

# Update and install base packages
RUN apt-get update \
  && apt-get upgrade -yq \
  && apt-get install -yq \
    aptitude \
    git \
    make \
    gcc \
    cpp \
    binutils \
    bash-completion \
    dnsutils \
    curl \
    wget \
    vim \
    htop \
    net-tools \
    iputils-ping \
    openssh-server \
    sudo \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/run/sshd \
  && mkdir -p /root/.ssh \
  && mkdir -p /root/bin

# Copy SSH authorized keys
COPY authorized_keys /root/.ssh/authorized_keys

# Copy utility scripts
COPY utils/apt.sh /root/bin/apt.sh

# Make scripts executable
RUN chmod +x /root/bin/*.sh

# Add custom bin to PATH
RUN echo 'export PATH=/root/bin:$PATH' >> /root/.bashrc

# SSH configuration
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Set environment variables
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Expose SSH port
EXPOSE 22

# Start SSH daemon
CMD ["/usr/sbin/sshd", "-D"]
