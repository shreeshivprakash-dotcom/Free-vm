FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

# Update system
RUN apt update && apt upgrade -y

# Install full Kali CLI toolset (no GUI)
RUN apt install -y \
    kali-linux-headless \
    kali-tools-top10 \
    git curl wget vim nano net-tools dnsutils \
    python3 python3-pip \
    nmap hydra sqlmap nikto gobuster \
    metasploit-framework \
    john hashcat \
    aircrack-ng \
    tcpdump wireshark \
    && apt clean

# Set working directory
WORKDIR /root
