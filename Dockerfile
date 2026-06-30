FROM debian:bullseye-slim

# Install only essential packages
RUN apt-get update \
  && apt-get upgrade -yq \
  && apt-get install -yq \
    openssh-server \
    bash-completion \
    ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Create SSH run directory
RUN mkdir /var/run/sshd

# Copy SSH authorized keys
COPY authorized_keys /root/.ssh/authorized_keys

# Set proper permissions for SSH
RUN chmod 600 /root/.ssh/authorized_keys \
  && chmod 700 /root/.ssh

# SSH login fix - disable pam_loginuid requirement
RUN sed -i 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' /etc/pam.d/sshd

# SSH configuration tweaks for better security
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
  && echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config \
  && echo "PasswordAuthentication no" >> /etc/ssh/sshd_config \
  && echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config \
  && echo "UsePAM yes" >> /etc/ssh/sshd_config

# Set environment variable
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Expose SSH port
EXPOSE 22

# Start SSH daemon
CMD ["/usr/sbin/sshd", "-D"]
