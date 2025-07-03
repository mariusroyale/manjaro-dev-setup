#!/bin/bash
set -e

# Prevent script from being run as root
if [[ "$EUID" -eq 0 ]]; then
  echo -e "\033[0;31m[ERROR]\033[0m ❌ Do NOT run this script as root!"
  echo -e "   This script is designed for a normal user with sudo privileges."
  echo -e "   Running it as root can break paths, permissions, and tool installs."
  echo -e "\n\033[1;33m👉 Please log in as your user and re-run the script.\033[0m"
  exit 1
fi

# This installer is for: Manjaro KDE (Arch-based)

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; PURPLE='\033[0;35m'; NC='\033[0m'
log()     { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARNING]${NC} $1"; }
header()  { echo -e "${PURPLE}$1${NC}"; }

# Track installed packages and versions
declare -A INSTALLED
declare -A VERSIONS

header "📦 Updating system..."
sudo pacman -Syu --noconfirm

PACKAGES=(
    curl
    wget
    gnupg
    unzip
    base-devel
    git
    go
    python
    python-pip
    python-virtualenv
    python-build
    sqlite
    postgresql
    redis
    brave
    libreoffice
    vlc
    obs-studio
    thunderbird
    qbittorrent
    kde-partitionmanager
    docker
    docker-compose
)

header "🧰 Installing CLI & GUI tools via pacman..."
for pkg in "${PACKAGES[@]}"; do
  if sudo pacman -S --noconfirm --needed "$pkg"; then
    INSTALLED["$pkg"]=1
    VERSIONS["$pkg"]=$(pacman -Qi "$pkg" | grep Version | awk '{print $3}')
    success "✅ $pkg (v${VERSIONS[$pkg]})"
  else
    INSTALLED["$pkg"]=0
    warn "⚠️  Failed to install $pkg"
  fi
done

# Symlink batcat to bat if needed
command -v batcat >/dev/null && ! command -v bat && sudo ln -s "$(which batcat)" /usr/local/bin/bat

# Enable services
if systemctl list-unit-files | grep -q docker.service; then
  sudo systemctl enable --now docker.service
fi

# Add user to docker group
sudo usermod -aG docker "$USER"

# # SSH Key generation
# SSH_KEY="$HOME/.ssh/id_rsa"
# if [ ! -f "$SSH_KEY" ]; then
#   log "Generating SSH key..."
#   ssh-keygen -t rsa -b 4096 -C "$USER@$(hostname)" -f "$SSH_KEY" -N ""
#   success "SSH key generated."
# else
#   log "SSH key already exists."
# fi

# NVM + Node.js
header "✅ Installing Node.js via NVM..."
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

if [ -s "$NVM_DIR/nvm.sh" ]; then
  source "$NVM_DIR/nvm.sh"
fi

nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

INSTALLED["node"]=1
VERSIONS["node"]=$(node -v | cut -c2-)
VERSIONS["npm"]=$(npm -v)

# TypeScript
log "Installing TypeScript globally..."
npm install -g typescript && {
  VERSIONS["typescript"]=$(tsc --version | awk '{print $2}')
  INSTALLED["typescript"]=1
}

# Rustup and Cargo tools
header "🦀 Setting up Rust..."

# Install rustup from official source
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Source cargo environment
source "$HOME/.cargo/env"

# Install Nushell using cargo
if ! command -v nu &>/dev/null; then
  cargo install nu && {
    INSTALLED["cargo:nu"]=1
    VERSIONS["cargo:nu"]=$(nu --version | awk '{print $2}')
  }
else
  INSTALLED["cargo:nu"]=1
  VERSIONS["cargo:nu"]=$(nu --version | awk '{print $2}')
  success "Nushell already installed (v${VERSIONS["cargo:nu"]})"
fi

# # Zed (via script, not available in pacman)
# header "✏️ Installing Zed Editor..."
# if curl -fsSL https://zed.dev/install.sh | sh; then
#   INSTALLED["zed"]=1
# else
#   INSTALLED["zed"]=0
# fi

# Cleanup
header "🧹 Cleanup..."
sudo pacman -Qtdq &>/dev/null && sudo pacman -Rns --noconfirm $(pacman -Qtdq) || true

# Summary
clear
header "🎉 Setup Complete!"
SUMMARY_LOG="$HOME/setup-summary.log"

{
  echo "🗓️  Setup completed on: $(date)"
  for key in "${!INSTALLED[@]}"; do
    if [ "${INSTALLED[$key]}" -eq 1 ]; then
      emoji="✅"
      version="${VERSIONS[$key]:-unknown}"
      printf "%s %-20s • version: %s\n" "$emoji" "$key" "$version"
    else
      emoji="❌"
      printf "%s %-20s • Failed or Skipped\n" "$emoji" "$key"
    fi
  done
} | tee "$SUMMARY_LOG"

echo -e "${BLUE}[INFO]${NC} Log saved to: ${YELLOW}$SUMMARY_LOG${NC}"
