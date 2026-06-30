# Debian-SSH

Debian-based Docker image with SSH and Supervisor for Railway deployment.

## Quick Start

### Local Development
```bash
# Build
docker build -t debian-ssh .

# Run
docker run -d -p 2222:22 --name debian-ssh-container debian-ssh

# Test SSH
ssh -p 2222 root@localhost
