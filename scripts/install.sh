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
        Darwin) OS="Darwin" ;;
        Linux) OS="Linux" ;;
        *) printf "Operating system ${OS} is not supported\n"; exit 1 ;;
    esac
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
   if [[ -n "$PROFILE_FILE" ]]; then
     if ! grep -q "\.kriti" $PROFILE_FILE; then
        printf "\n${bright_blue}Updating profile ${reset}$PROFILE_FILE\n"
        printf "\n# Kriti\nexport PATH=\"\$PATH:$INSTALL_DIRECTORY\"\n" >> $PROFILE_FILE
        printf "\nKriti will be available when you open a new terminal.\n"
        printf "If you want to make Kriti available in this terminal, please run:\n"
        printf "\nsource $PROFILE_FILE\n"
     fi
   else
     printf "\n${bright_blue}Unable to detect profile file location. ${reset}Please add the following to your profile file:\n"
     printf "\nexport PATH=\"$INSTALL_DIRECTORY:\$PATH\"\n"
   fi
}

install_kriti_cli() {
  URL_PREFIX="https://github.com/vinaygaykar/kriti-cli-archive/releases/latest/download/"
  TARGET="${OS}_$ARCH"

  printf "${bright_blue}Downloading ${reset}$TARGET ...\n"

  URL="$URL_PREFIX/kriti_$TARGET.tar.gz"
  DOWNLOAD_FILE=$(mktemp -t kriti.XXXXXXXXXX)

  curl --progress-bar -L "$URL" -o "$DOWNLOAD_FILE"
  printf "\n${bright_blue}Installing to ${reset}$INSTALL_DIRECTORY\n"
  mkdir -p $INSTALL_DIRECTORY
  tar -C $INSTALL_DIRECTORY -zxf $DOWNLOAD_FILE kriti
  rm -f $DOWNLOAD_FILE
}

# do everything in main, so that partial downloads of this file don't mess up the installation
main() {
  printf "\nWelcome to the Kriti installer!\n"

  probe_arch
  probe_os

  INSTALL_DIRECTORY="$HOME/.kriti"
  install_kriti_cli
  update_profile

  printf "\nKriti CLI installed!\n\n"
  printf "To get started run ${bright_blue}kriti login${reset}.\n\n"
}

main
