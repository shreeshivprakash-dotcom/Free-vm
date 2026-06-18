FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

# Install base tools (light during build)
RUN apt update && apt install -y \
    curl git wget vim nano python3 python3-pip \
    net-tools dnsutils \
    && apt clean

# Create setup script (run after container starts)
RUN echo '#!/bin/bash\n\
apt update\n\
apt install -y kali-linux-headless kali-tools-top10\n\
apt install -y nmap hydra sqlmap nikto gobuster\n\
apt install -y john hashcat\n\
echo "✅ Kali Rolling ready with tools"\n\
' > /root/setup.sh && chmod +x /root/setup.sh

WORKDIR /root
``
