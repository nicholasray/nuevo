#!/bin/sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


trap cleanup INT

set -e

function cleanup() {
  fancy_echo "Exiting..."
  exit 1
}

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

fancy_echo "Sit back and relax..."

mkdir -p "$HOME/Development"

if [ ! -d  "$HOME/dotfiles" ]; then
  fancy_echo "Cloning dot_files..."
  git clone git@github.com:nicholasray/dotfiles.git "$HOME/dotfiles"
fi

# Show hidden files in mac
fancy_echo "Enable apple finder to show hidden files..."
defaults write com.apple.finder AppleShowAllFiles YES

# Install brew
if ! command -v brew >/dev/null; then
  fancy_echo "Installing homebrew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

function install_pkg_if_absent() {
  local pkg="$1"

  fancy_echo "Checking if $pkg exists..."
  if ! brew ls --versions $pkg > /dev/null 2>&1; then
    fancy_echo "Installing $1..."
    brew install "$1"
  fi
}

# Install Terminal Stuff
install_pkg_if_absent zsh
install_pkg_if_absent tmux
install_pkg_if_absent git
install_pkg_if_absent openssl
install_pkg_if_absent neovim
install_pkg_if_absent postgresql
install_pkg_if_absent mysql
install_pkg_if_absent chruby
install_pkg_if_absent ruby-install
install_pkg_if_absent redis

# Install Brew Cask to make app installation easy
fancy_echo "Tapping cask..."
brew tap homebrew/cask

function install_app_if_absent() {
  local pkg="$1"

  fancy_echo "Checking if $pkg exists..."
  if ! brew cask ls --versions $pkg > /dev/null 2>&1; then
    fancy_echo "Installing $1..."
    brew cask install --force "$1"
  fi
}

install_app_if_absent google-chrome
install_app_if_absent spectacle
install_app_if_absent docker
install_app_if_absent firefox
install_app_if_absent sourcetree
install_app_if_absent iterm2
install_app_if_absent slack

# Install recent ruby version

if [ ! -d "$HOME/.rubies/ruby-2.5.1" ]; then
  fancy_echo "Installing Ruby 2.5.1..."
  ruby-install ruby-2.5.1
fi

fancy_echo "SUCCESS! Enjoy your new setup!"
exit 0
