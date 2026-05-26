#!/bin/bash

# Install Script for Perfect World 1.7.6 Source (Debian 12 / Ubuntu 22.04+)
# Usage: chmod +x install_debian12.sh && sudo ./install_debian12.sh
#
# Works with any user — no hardcoded /root/ paths.

VERSION="2.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}[+] Starting Setup (v${VERSION})...${NC}"

# 1. Check root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[!] This script must be run as root (sudo).${NC}"
    exit 1
fi

# 2. Install dependencies
echo -e "${GREEN}[+] Installing build dependencies...${NC}"
apt-get update -qq
apt-get install -y --no-install-recommends build-essential cmake gcc g++ make \
    libxml2-dev libssl-dev libpcre3-dev zlib1g-dev \
    libmariadb-dev-compat libmariadb-dev libreadline-dev \
    ant default-jdk dos2unix libxml-dom-perl \
    libcurl4-openssl-dev libjsoncpp-dev

# 3. Determine repo directory (use script location or current directory)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/build.sh" ]; then
    REPO_DIR="$SCRIPT_DIR"
    echo -e "${GREEN}[+] Using existing repo at $REPO_DIR${NC}"
else
    REPO_DIR="$(pwd)/176source"
    REPO_URL="https://github.com/StateDev08/176source.git"
    if [ -d "$REPO_DIR" ]; then
        echo -e "${YELLOW}[!] Directory $REPO_DIR already exists. Pulling latest changes...${NC}"
        cd "$REPO_DIR"
        git pull
    else
        echo -e "${GREEN}[+] Cloning Repository from $REPO_URL...${NC}"
        git clone "$REPO_URL" "$REPO_DIR"
    fi
fi

cd "$REPO_DIR"

# 4. Fix Permissions and Line Endings
echo -e "${GREEN}[+] Fixing permissions and line endings...${NC}"
dos2unix -v build.sh install_debian12.sh 2>/dev/null || true
chmod +x build.sh

if [ -f "share/rpcgen" ]; then
    chmod +x share/rpcgen
    dos2unix share/rpcgen 2>/dev/null || true
fi

if [ -f "share/rpc/xmlcoder.pl" ]; then
    chmod +x share/rpc/xmlcoder.pl
    dos2unix share/rpc/xmlcoder.pl 2>/dev/null || true
fi

# 5. Prepare Output Directories
echo -e "${GREEN}[+] Creating Output Directories in /home...${NC}"
mkdir -p /home/gamed /home/gfactiond /home/gauthd /home/uniquenamed
mkdir -p /home/gamedbd /home/gdeliveryd /home/glinkd /home/gacd /home/logservice

# 6. Build
echo -e "${GREEN}[+] Starting Build Process...${NC}"
echo -e "${YELLOW}[+] Log will be saved to /var/log/build_pw.log${NC}"

./build.sh all 2>&1 | tee /var/log/build_pw.log

echo -e "${GREEN}[+] Setup and Build Finished!${NC}"
