#!/usr/bin/env bash
set -euo pipefail

# scripts/build_tools.sh
# Build/install aircrack-ng (for cap2hccapx) and hcxtools (for hcxpcapngtool)
# Usage: ./scripts/build_tools.sh [--yes]
# Warning: this script installs packages and runs commands that may require sudo.

SKIP_CONFIRM=0
if [[ "${1:-}" == "--yes" || "${1:-}" == "-y" ]]; then
  SKIP_CONFIRM=1
fi

echo "This script will perform the following actions on this machine:"
echo "  - Install required packages (apt)"
echo "  - Clone/build/install aircrack-ng (cap2hccapx)"
echo "  - Clone/build/install hcxtools (hcxpcapngtool)"
echo
echo "Only run this on a system you control and where you have permission to install software."

if [[ $SKIP_CONFIRM -ne 1 ]]; then
  read -r -p "Do you want to continue? [y/N] " RESP
  case "$RESP" in
    [yY][eE][sS]|[yY])
      echo "Proceeding..." ;;
    *)
      echo "Aborted by user.";
      exit 1 ;;
  esac
fi

# Detect if apt is available
if ! command -v apt >/dev/null 2>&1; then
  echo "apt not found. This script is designed for Debian/Ubuntu/WSL systems." >&2
  exit 2
fi

# Install build dependencies (uses sudo)
sudo apt update
sudo apt install -y build-essential autoconf automake libtool pkg-config libssl-dev libnl-3-dev libnl-genl-3-dev libpcap-dev git

# Build/install aircrack-ng
REPO_DIR="/usr/src/aircrack-ng"
if [[ ! -d "$REPO_DIR" ]]; then
  sudo mkdir -p "$REPO_DIR"
  sudo chown "$(id -u):$(id -g)" "$REPO_DIR"
  git clone https://github.com/aircrack-ng/aircrack-ng.git "$REPO_DIR"
fi
cd "$REPO_DIR"
# Try to build; tolerate some configure/autoreconf failures on different systems
autoreconf -i || true
./configure || true
make -j"$(nproc)" || true
sudo make install || true

# Build/install hcxtools
HCX_DIR="/usr/src/hcxtools"
if [[ ! -d "$HCX_DIR" ]]; then
  sudo mkdir -p "$HCX_DIR"
  sudo chown "$(id -u):$(id -g)" "$HCX_DIR"
  git clone https://github.com/ZerBea/hcxtools.git "$HCX_DIR"
fi
cd "$HCX_DIR"
make -j"$(nproc)" || true
sudo make install || true

# Final checks
echo
echo "Build/install steps finished. Verify the tools are available in PATH:"
if command -v hcxpcapngtool >/dev/null 2>&1; then
  echo " - hcxpcapngtool: $(command -v hcxpcapngtool)"
else
  echo " - hcxpcapngtool: NOT FOUND"
fi
if command -v cap2hccapx >/dev/null 2>&1; then
  echo " - cap2hccapx: $(command -v cap2hccapx)"
else
  echo " - cap2hccapx: NOT FOUND"
fi

echo "If any tools are NOT FOUND, check the build output above or run the commands manually."