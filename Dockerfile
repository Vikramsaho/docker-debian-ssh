FROM debian:bullseye-slim

# Update and upgrade packages
RUN apt-get update \
  && apt-get upgrade -yq \
  && apt-get install -yq aptitude git make gcc cpp binutils bash-completion dnsutils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install SSH server
RUN apt-get update \
  && apt-get install -yq openssh-server \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Create SSH runtime directory
RUN mkdir /var/run/sshd

# Copy SSH authorized keys
COPY authorized_keys /root/.ssh/authorized_keys

# Copy utilities
COPY utils/apt.sh /root/bin/apt.sh

# Make scripts executable
RUN chmod +x /root/bin/*.sh

# Add custom bin to PATH
RUN echo 'export PATH=/root/bin:$PATH' >> /root/.bashrc

# SSH configuration
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Environment settings
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Expose SSH port
EXPOSE 22

# Start SSH daemon
CMD ["/usr/sbin/sshd", "-D"]
