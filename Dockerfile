FROM debian:bullseye-slim

# Install SSH server and essentials
RUN apt-get update && \
    apt-get install -y \
        openssh-server \
        supervisor \
        ca-certificates \
        curl \
        wget \
        bash-completion \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/run/sshd \
    && mkdir -p /root/.ssh \
    && mkdir -p /var/log/supervisor

# Copy authorized_keys (note: using .txt extension)
COPY authorized_keys.txt /root/.ssh/authorized_keys

# Set proper permissions
RUN chmod 600 /root/.ssh/authorized_keys \
    && chmod 700 /root/.ssh

# Configure SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    echo "AllowUsers root" >> /etc/ssh/sshd_config && \
    echo "UsePAM yes" >> /etc/ssh/sshd_config && \
    echo "LogLevel DEBUG3" >> /etc/ssh/sshd_config

# CRITICAL FIX: Fix PAM session issue
RUN sed -i 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' /etc/pam.d/sshd

# Copy utilities
COPY utils/apt.sh /root/bin/apt.sh
RUN chmod +x /root/bin/apt.sh

# Add PATH
RUN echo 'export PATH=/root/bin:$PATH' >> /root/.bashrc

# Create supervisor config
RUN echo "[supervisord]" > /etc/supervisor/conf.d/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "[program:sshd]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=/usr/sbin/sshd -D -e" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autostart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/supervisord.conf

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
