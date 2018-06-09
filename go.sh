#!/bin/sh

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

fancy_echo "Sit back and relax..."

# Show hidden files in mac
fancy_echo "Enable apple finder to show hidden files..."
defaults write com.apple.finder AppleShowAllFiles YES

# Install brew
if ! command -v brew >/dev/null; then
  fancy_echo "Installing homebrew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Install Brew Cask to make app installation easy
fancy_echo "Installing cask..."
brew tap homebrew/cask

brew install zsh
brew install tmux
brew install git
brew install openssl
brew install neovim
brew install postgresql
brew install mysql
brew install chruby
brew install ruby-install

fancy_echo "Installing Ruby 2.5.1..."
ruby-install ruby-2.5.1
