#!/bin/sh

# This script is for installing the latest version of Kriti CLI on your machine.

set -e

# Terminal ANSI escape codes.
reset="\033[0m"
bright_blue="${reset}\033[34;1m"

probe_arch() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="x86_64"  ;;
        aarch64) ARCH="arm64" ;;
        arm64) ARCH="arm64" ;;
        *) printf "Architecture ${ARCH} is not supported\n"; exit 1 ;;
    esac
}

probe_os() {
    OS=$(uname -s)
    case $OS in
        Darwin) OS="darwin" ;;
        Linux) OS="linux" ;;
        *) printf "Operating system ${OS} is not supported\n"; exit 1 ;;
    esac
}

get_latest_version() {
    VERSION=$(curl -s -L "https://kriti.blog/version/kriti-cli/latest")
    echo "$VERSION" | tr -d '[:space:]'
}

detect_profile() {
  local DETECTED_PROFILE
  DETECTED_PROFILE=''
  local SHELLTYPE
  SHELLTYPE="$(basename "/$SHELL")"

  if [ "$SHELLTYPE" = "bash" ]; then
    if [ -f "$HOME/.bashrc" ]; then
      DETECTED_PROFILE="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
      DETECTED_PROFILE="$HOME/.bash_profile"
    fi
  elif [ "$SHELLTYPE" = "zsh" ]; then
    DETECTED_PROFILE="${ZDOTDIR:-$HOME}/.zshrc"
  elif [ "$SHELLTYPE" = "fish" ]; then
    DETECTED_PROFILE="$HOME/.config/fish/conf.d/kriti.fish"
  fi

  if [ -z "$DETECTED_PROFILE" ]; then
    if [ -f "$HOME/.profile" ]; then
      DETECTED_PROFILE="$HOME/.profile"
    elif [ -f "$HOME/.bashrc" ]; then
      DETECTED_PROFILE="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
      DETECTED_PROFILE="$HOME/.bash_profile"
    elif [ -f "${ZDOTDIR:-$HOME}/.zshrc" ]; then
      DETECTED_PROFILE="${ZDOTDIR:-$HOME}/.zshrc"
    elif [ -d "$HOME/.config/fish" ]; then
      DETECTED_PROFILE="$HOME/.config/fish/conf.d/kriti.fish"
    fi
  fi

  if [ ! -z "$DETECTED_PROFILE" ]; then
    echo "$DETECTED_PROFILE"
  fi
}

update_profile() {
   PROFILE_FILE=$(detect_profile)
   VERSION_DIR="$BASE_DIRECTORY/v$VERSION"
   
   if [[ -n "$PROFILE_FILE" ]]; then
     if ! grep -q "\.kriti" $PROFILE_FILE; then
        # Remove any existing Kriti paths
        sed -i.bak "/\.kriti/d" "$PROFILE_FILE"
        
        printf "\n${bright_blue}Updating profile ${reset}$PROFILE_FILE\n"
        printf "\nexport PATH=\"$VERSION_DIR:\$PATH\"\n" >> "$PROFILE_FILE"
        
        # Remove backup file
        rm -f "$PROFILE_FILE.bak"
     fi
   else
     printf "\n${bright_blue}Unable to detect profile file location. ${reset}Please add the following to your profile file:\n"
     printf "\nexport PATH=\"$INSTALL_DIRECTORY:\$PATH\"\n"
   fi
}

install_kriti_cli() {
  URL_PREFIX="https://github.com/vinaygaykar/kriti-cli-archive/releases/download"
  TARGET="${OS}_$ARCH"
  VERSION_DIR="$BASE_DIRECTORY/v$VERSION"

  printf "${bright_blue}Downloading ${reset}$TARGET ...\n"

  URL="$URL_PREFIX/$VERSION/kriti_$TARGET.tar.gz"
  DOWNLOAD_FILE=$(mktemp -t kriti.XXXXXXXXXX)

  curl --progress-bar -L "$URL" -o "$DOWNLOAD_FILE"
  printf "\n${bright_blue}Installing to ${reset}$VERSION_DIR\n"
    
  # Create version directory
  mkdir -p "$VERSION_DIR"
    
  # Extract to version directory
  tar -C "$VERSION_DIR" -zxf "$DOWNLOAD_FILE" kriti
  rm -f "$DOWNLOAD_FILE"
}

# do everything in main, so that partial downloads of this file don't mess up the installation
main() {
  printf "\nWelcome to the Kriti installer!\n"

  probe_arch
  probe_os

  BASE_DIRECTORY="$HOME/.kriti"
  VERSION=$(get_latest_version)
  
  install_kriti_cli
  update_profile

  printf "\n=============================================================="
  printf "\nKriti CLI installed!"
  printf "\nCLOSE THIS WINDOW, OPEN NEW ONE AND RUN ${bright_blue}kriti${reset} FOR CHANGES TO TAKE EFFECT."
  printf "\n=============================================================="
}

main
