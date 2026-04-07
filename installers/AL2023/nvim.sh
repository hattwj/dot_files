#!/usr/bin/env bash
# Build and install Neovim from source on AL2023
set -euo pipefail

NVIM_BRANCH="${NVIM_BRANCH:-release-0.12}"
SRC_DIR="$HOME/src"
JOBS=$(( $(nproc) / 2 ))
[[ "${JOBS}" -lt 1 ]] && JOBS=1

# Check if already on the right version
if command -v nvim &>/dev/null; then
  current="$(nvim --version | head -1)"
  target_ver="${NVIM_BRANCH#release-}"
  if [[ "$current" == *"$target_ver"* ]]; then
    echo "Neovim ${target_ver} already installed: ${current}"
    exit 0
  fi
  echo "Upgrading nvim from ${current} to ${NVIM_BRANCH}"
fi

# Prereqs
sudo dnf install -y gcc gcc-c++ cmake cmake3 make gettext ninja-build python3-pip
pip3 install --user neovim --upgrade 2>/dev/null || true

# Clone or update source
mkdir -p "${SRC_DIR}"
cd "${SRC_DIR}"
if [[ ! -d "neovim" ]]; then
  git clone https://github.com/neovim/neovim.git
fi

cd neovim
git fetch --all --tags --force
git checkout "${NVIM_BRANCH}" || { echo "Branch ${NVIM_BRANCH} not found"; exit 1; }
git pull

# Clean build (rm -rf, not distclean — 0.12 changed build system)
rm -rf build .deps
make -j"${JOBS}" CMAKE_BUILD_TYPE=RelWithDebInfo

# Install
sudo rm -rf /usr/local/share/nvim/runtime
sudo make install

# Fix permissions so subsequent builds don't need sudo
sudo chown -R "$(id -un):$(id -gn)" build/ .deps/ 2>/dev/null || true

echo "Installed: $(nvim --version | head -1)"
