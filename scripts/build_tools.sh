#!/usr/bin/env bash
set -euo pipefail

# scripts/build_tools.sh
# Build/install aircrack-ng (for cap2hccapx) and hcxtools (for hcxpcapngtool)
# Usage: sudo ./scripts/build_tools.sh
# Warning: this script runs commands with sudo and will install packages.

if [[ $(id -u) -ne 0 ]]; then
  echo "Please run as root or with sudo: sudo $0" >&2
  exit 1
fi

apt update
apt install -y build-essential autoconf automake libtool pkg-config libssl-dev libnl-3-dev libnl-genl-3-dev libpcap-dev git

# build aircrack-ng
if [[ ! -d /usr/src/aircrack-ng ]]; then
  git clone https://github.com/aircrack-ng/aircrack-ng.git /usr/src/aircrack-ng
fi
cd /usr/src/aircrack-ng
autoreconf -i || true
./configure || true
make -j$(nproc) || true
make install || true

# build hcxtools
if [[ ! -d /usr/src/hcxtools ]]; then
  git clone https://github.com/ZerBea/hcxtools.git /usr/src/hcxtools
fi
cd /usr/src/hcxtools
make -j$(nproc) || true
make install || true

echo "Build/install completed. Ensure /usr/local/bin is in PATH and run: which hcxpcapngtool cap2hccapx"
