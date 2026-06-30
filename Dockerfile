FROM debian:bullseye-slim

# Build arguments for username and password
ARG USERNAME=debianuser
ARG USERPASS=debianpass

# Update and upgrade packages
RUN apt-get update \
  && apt-get upgrade -yq \
  && apt-get install -yq aptitude git make gcc cpp binutils bash-completion dnsutils openssh-server \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Create user with provided credentials
RUN useradd -m -s /bin/bash ${USERNAME} \
  && echo "${USERNAME}:${USERPASS}" | chpasswd

# Continue with SSH setup...
RUN mkdir -p /home/${USERNAME}/.ssh \
  && mkdir /var/run/sshd

COPY authorized_keys /home/${USERNAME}/.ssh/authorized_keys
COPY utils/apt.sh /home/${USERNAME}/bin/apt.sh

RUN chmod +x /home/${USERNAME}/bin/*.sh \
  && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

RUN echo 'export PATH=$HOME/bin:$PATH' >> /home/${USERNAME}/.bashrc

RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
