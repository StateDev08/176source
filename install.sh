#!/bin/bash
#
# Universal Install Script for Perfect World 1.7.6 Server
#
# Supported distributions:
#   - Ubuntu 24.04 / 25.04
#   - Debian 11 (Bullseye) / 12 (Bookworm) / 13 (Trixie)
#   - CentOS Stream 9 / Rocky Linux 9 / AlmaLinux 9 / RHEL 9
#
# Usage:
#   chmod +x install.sh && sudo ./install.sh           # install + build
#   sudo ./install.sh --deps-only                      # only install dependencies
#   sudo ./install.sh --build-only                     # only build (skip dependency install)
#
# Works with any user — no hardcoded paths.
#

set -euo pipefail

VERSION="3.0"

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[+]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
log_error() { echo -e "${RED}[✗]${NC} $*"; }
log_step()  { echo -e "${CYAN}[»]${NC} ${BOLD}$*${NC}"; }

# ─── Parse Arguments ─────────────────────────────────────────────────────────
DEPS_ONLY=false
BUILD_ONLY=false

for arg in "$@"; do
    case "$arg" in
        --deps-only)  DEPS_ONLY=true ;;
        --build-only) BUILD_ONLY=true ;;
        --help|-h)
            echo "Usage: sudo $0 [--deps-only | --build-only]"
            echo ""
            echo "  --deps-only   Only install system dependencies (skip build)"
            echo "  --build-only  Only run the build (skip dependency installation)"
            echo ""
            echo "Supported: Ubuntu 24/25, Debian 11/12/13, CentOS/Rocky/Alma 9"
            exit 0
            ;;
    esac
done

# ─── Root Check ───────────────────────────────────────────────────────────────
if [ "$(id -u)" -ne 0 ]; then
    log_error "This script must be run as root (sudo)."
    exit 1
fi

# ─── Detect Distribution ─────────────────────────────────────────────────────
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID="${ID,,}"
        DISTRO_VERSION="${VERSION_ID:-unknown}"
        DISTRO_NAME="${PRETTY_NAME:-$ID $VERSION_ID}"
    elif [ -f /etc/centos-release ]; then
        DISTRO_ID="centos"
        DISTRO_VERSION=$(grep -oE '[0-9]+' /etc/centos-release | head -1)
        DISTRO_NAME=$(cat /etc/centos-release)
    else
        log_error "Cannot detect distribution. /etc/os-release not found."
        exit 1
    fi

    case "$DISTRO_ID" in
        ubuntu)      DISTRO_FAMILY="debian" ;;
        debian)      DISTRO_FAMILY="debian" ;;
        centos)      DISTRO_FAMILY="rhel" ;;
        rocky)       DISTRO_FAMILY="rhel" ;;
        almalinux)   DISTRO_FAMILY="rhel" ;;
        rhel)        DISTRO_FAMILY="rhel" ;;
        *)
            log_warn "Unknown distribution: $DISTRO_ID ($DISTRO_NAME)"
            log_warn "Attempting Debian-style install..."
            DISTRO_FAMILY="debian"
            ;;
    esac

    log_info "Detected: ${BOLD}$DISTRO_NAME${NC} (family: $DISTRO_FAMILY)"
}

# ─── Install Dependencies (Debian/Ubuntu) ────────────────────────────────────
install_deps_debian() {
    log_step "Installing dependencies via apt..."

    apt-get update -qq

    # Core build tools
    local PACKAGES=(
        build-essential gcc g++ make cmake git
        libxml2-dev libssl-dev libpcre2-dev zlib1g-dev
        libreadline-dev dos2unix
        libcurl4-openssl-dev libjsoncpp-dev
    )

    # Java + Ant (for cskill build)
    PACKAGES+=(ant default-jdk)

    # Perl XML (for rpcgen)
    PACKAGES+=(libxml-dom-perl)

    # MariaDB client headers
    # Debian 11+ and Ubuntu 22.04+ use libmariadb-dev-compat for MySQL compatibility
    if apt-cache show libmariadb-dev-compat &>/dev/null; then
        PACKAGES+=(libmariadb-dev-compat libmariadb-dev)
    elif apt-cache show libmysqlclient-dev &>/dev/null; then
        PACKAGES+=(libmysqlclient-dev)
    elif apt-cache show default-libmysqlclient-dev &>/dev/null; then
        PACKAGES+=(default-libmysqlclient-dev)
    else
        log_warn "Could not find MySQL/MariaDB dev package. You may need to install it manually."
    fi

    # PCRE: Debian 13+ / Ubuntu 25+ may only have libpcre2-dev
    if ! apt-cache show libpcre3-dev &>/dev/null 2>&1; then
        log_warn "libpcre3-dev not available, trying libpcre2-dev..."
        # Remove libpcre3-dev from array and add libpcre2-dev
        PACKAGES=("${PACKAGES[@]/libpcre3-dev/}")
        PACKAGES+=(libpcre2-dev)
    fi

    apt-get install -y --no-install-recommends "${PACKAGES[@]}"

    log_info "apt dependencies installed."
}

# ─── Install Dependencies (RHEL/CentOS/Rocky/Alma) ───────────────────────────
install_deps_rhel() {
    log_step "Installing dependencies via dnf/yum..."

    # Determine package manager
    local PKG_MGR="dnf"
    if ! command -v dnf &>/dev/null; then
        PKG_MGR="yum"
    fi

    # Enable required repos
    if [ "$DISTRO_ID" = "centos" ] || [ "$DISTRO_ID" = "rhel" ]; then
        $PKG_MGR install -y epel-release 2>/dev/null || true
        # CentOS Stream 9 / RHEL 9: enable CRB (CodeReady Builder) for devel packages
        if command -v dnf &>/dev/null; then
            dnf config-manager --set-enabled crb 2>/dev/null || \
            dnf config-manager --set-enabled powertools 2>/dev/null || true
        fi
    elif [ "$DISTRO_ID" = "rocky" ] || [ "$DISTRO_ID" = "almalinux" ]; then
        $PKG_MGR install -y epel-release 2>/dev/null || true
        dnf config-manager --set-enabled crb 2>/dev/null || \
        dnf config-manager --set-enabled powertools 2>/dev/null || true
    fi

    # Core build tools
    $PKG_MGR groupinstall -y "Development Tools" 2>/dev/null || \
    $PKG_MGR install -y gcc gcc-c++ make cmake git

    # Development libraries
    local PACKAGES=(
        libxml2-devel openssl-devel pcre-devel zlib-devel
        readline-devel dos2unix
        libcurl-devel jsoncpp-devel
    )

    # MariaDB client headers
    if $PKG_MGR list available mariadb-devel &>/dev/null 2>&1; then
        PACKAGES+=(mariadb-devel)
    elif $PKG_MGR list available mysql-devel &>/dev/null 2>&1; then
        PACKAGES+=(mysql-devel)
    elif $PKG_MGR list available community-mysql-devel &>/dev/null 2>&1; then
        PACKAGES+=(community-mysql-devel)
    else
        log_warn "Could not find MySQL/MariaDB devel package. You may need to install it manually."
    fi

    # Java + Ant
    PACKAGES+=(java-17-openjdk-devel)
    if $PKG_MGR list available ant &>/dev/null 2>&1; then
        PACKAGES+=(ant)
    else
        log_warn "Apache Ant not found in repos. Install manually or skip cskill build."
    fi

    # Perl XML::DOM
    if $PKG_MGR list available perl-XML-DOM &>/dev/null 2>&1; then
        PACKAGES+=(perl-XML-DOM)
    else
        log_warn "perl-XML-DOM not found. rpcgen may not work. Try: cpan XML::DOM"
    fi

    $PKG_MGR install -y "${PACKAGES[@]}"

    # MySQL include compatibility: create symlink if needed
    # CentOS/Rocky puts headers in /usr/include/mysql/ which is what the code expects
    if [ -d "/usr/include/mariadb" ] && [ ! -d "/usr/include/mysql" ]; then
        log_info "Creating /usr/include/mysql -> /usr/include/mariadb symlink..."
        ln -sf /usr/include/mariadb /usr/include/mysql
    fi

    log_info "dnf/yum dependencies installed."
}

# ─── Verify Toolchain ────────────────────────────────────────────────────────
verify_toolchain() {
    log_step "Verifying build toolchain..."

    local ERRORS=0

    # Check GCC version (need >= 10 for C++20)
    if command -v g++ &>/dev/null; then
        local GCC_VER
        GCC_VER=$(g++ -dumpversion | cut -d. -f1)
        if [ "$GCC_VER" -lt 10 ]; then
            log_error "g++ version $GCC_VER is too old. Need >= 10 for C++20 support."
            log_warn "On Debian 11: apt install g++-12 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 100"
            ERRORS=1
        else
            log_info "g++ version: $(g++ --version | head -1)"
        fi
    else
        log_error "g++ not found!"
        ERRORS=1
    fi

    # Check make
    if command -v make &>/dev/null; then
        log_info "make: $(make --version | head -1)"
    else
        log_error "make not found!"
        ERRORS=1
    fi

    # Check mysql.h
    if [ -f "/usr/include/mysql/mysql.h" ] || [ -f "/usr/include/mariadb/mysql.h" ]; then
        log_info "MySQL/MariaDB headers: found"
    else
        log_warn "MySQL/MariaDB headers not found at expected location."
    fi

    # Check OpenSSL
    if [ -f "/usr/include/openssl/ssl.h" ]; then
        log_info "OpenSSL headers: found"
    else
        log_warn "OpenSSL headers not found."
    fi

    # Check libxml2
    if [ -f "/usr/include/libxml2/libxml/parser.h" ]; then
        log_info "libxml2 headers: found"
    else
        log_warn "libxml2 headers not found."
    fi

    if [ "$ERRORS" -ne 0 ]; then
        log_error "Toolchain verification failed. Fix the above issues before building."
        return 1
    fi

    log_info "Toolchain OK."
    return 0
}

# ─── Determine Repo Directory ────────────────────────────────────────────────
find_repo() {
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    if [ -f "$SCRIPT_DIR/build.sh" ]; then
        REPO_DIR="$SCRIPT_DIR"
        log_info "Using existing repo at $REPO_DIR"
    else
        REPO_DIR="$(pwd)/176source"
        REPO_URL="https://github.com/StateDev08/176source.git"
        if [ -d "$REPO_DIR" ]; then
            log_warn "Directory $REPO_DIR already exists. Pulling latest changes..."
            cd "$REPO_DIR"
            git pull
        else
            log_info "Cloning Repository from $REPO_URL..."
            git clone "$REPO_URL" "$REPO_DIR"
        fi
    fi
}

# ─── Fix Permissions ─────────────────────────────────────────────────────────
fix_permissions() {
    cd "$REPO_DIR"

    log_step "Fixing permissions and line endings..."

    # Fix line endings if dos2unix is available
    if command -v dos2unix &>/dev/null; then
        find . -maxdepth 1 -name "*.sh" -exec dos2unix -q {} \; 2>/dev/null || true
    fi

    chmod +x build.sh
    [ -f "share/rpcgen" ] && chmod +x share/rpcgen
    [ -f "share/rpc/xmlcoder.pl" ] && chmod +x share/rpc/xmlcoder.pl

    log_info "Permissions fixed."
}

# ─── Prepare Output Directories ──────────────────────────────────────────────
prepare_dirs() {
    log_step "Creating daemon output directories in /home..."

    local DIRS=(
        /home/gamed /home/gfactiond /home/gauthd /home/uniquenamed
        /home/gamedbd /home/gdeliveryd /home/glinkd /home/gacd /home/logservice
    )

    mkdir -p "${DIRS[@]}"
    log_info "Output directories ready."
}

# ─── Build ────────────────────────────────────────────────────────────────────
run_build() {
    cd "$REPO_DIR"

    log_step "Starting build process..."
    log_warn "Build log: /var/log/build_pw.log"

    ./build.sh all 2>&1 | tee /var/log/build_pw.log
    local BUILD_EXIT=${PIPESTATUS[0]}

    if [ "$BUILD_EXIT" -eq 0 ]; then
        log_info "Build completed successfully!"
    else
        log_error "Build failed with exit code $BUILD_EXIT. Check /var/log/build_pw.log"
        return "$BUILD_EXIT"
    fi
}

# ─── Print Summary ───────────────────────────────────────────────────────────
print_summary() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  Perfect World 1.7.6 Server — Install Summary${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "  Distribution:  ${BOLD}$DISTRO_NAME${NC}"
    echo -e "  Family:        $DISTRO_FAMILY"
    echo -e "  GCC:           $(g++ --version 2>/dev/null | head -1 || echo 'not found')"
    echo -e "  Repo:          $REPO_DIR"
    echo -e "  Build Log:     /var/log/build_pw.log"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo ""

    if [ "$DEPS_ONLY" = true ]; then
        log_info "Dependencies installed. Run './build.sh all' to build."
    elif [ "$BUILD_ONLY" = true ]; then
        log_info "Build finished."
    else
        log_info "Setup complete!"
    fi

    echo ""
    echo -e "  Daemon binaries will be in /home/<daemon>/"
    echo -e "  To rebuild:     cd $REPO_DIR && ./build.sh all"
    echo -e "  To install:     cd $REPO_DIR && ./build.sh install"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════════════

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}Perfect World 1.7.6 Server — Universal Installer v${VERSION}${NC}     ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  Ubuntu 24/25 · Debian 11/12/13 · CentOS/Rocky/Alma 9     ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

detect_distro

# Step 1: Install dependencies (unless --build-only)
if [ "$BUILD_ONLY" = false ]; then
    case "$DISTRO_FAMILY" in
        debian) install_deps_debian ;;
        rhel)   install_deps_rhel ;;
    esac
fi

# Step 2: Verify toolchain
verify_toolchain || exit 1

# Step 3: Find/clone repo
find_repo

# Step 4: Fix permissions
fix_permissions

# If --deps-only, stop here
if [ "$DEPS_ONLY" = true ]; then
    print_summary
    exit 0
fi

# Step 5: Prepare output directories
prepare_dirs

# Step 6: Build
run_build

# Done
print_summary
