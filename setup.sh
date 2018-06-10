#!/bin/sh
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

fancy_echo "You're about to have your computer setup in no time. Just sit back and relax..."

mkdir -p "$HOME/Development"

if [ ! -d  "$HOME/dotfiles" ]; then
  fancy_echo "Cloning dot_files..."
  git clone git@github.com:nicholasray/dotfiles.git "$HOME/dotfiles"
fi

function install_dotfiles() {
  cd $HOME

  for file in "$HOME/dotfiles/".*; do
    if [ "$file" == "$HOME/dotfiles/." ]; then
      continue
    fi

    if [ "$file" == "$HOME/dotfiles/.." ]; then
      continue
    fi

    if [ "$file" == "$HOME/dotfiles/.git" ]; then
      continue
    fi

    local sym_file_name="$( basename $file )" 
    local sym="$HOME/$sym_file_name"

    if [ ! -e $sym ]; then
      # file doesn't already exist
      ln -s "$file" "$sym"
    fi

    while true; do
      read -p "$sym already exists. Do you want to overwrite it? " yn
       case $yn in
         [Yy]* ) ln -sf "$file" "$sym"; break;;
         [Nn]* ) break;;
         * ) echo "Please answer yes or no.";;
       esac
    done
  done
}

fancy_echo "Installing dotfiles..."
install_dotfiles

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
    fancy_echo "Installing $pkg..."
    brew install "$pkg" $2
  fi
}

# Install Brews
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
install_pkg_if_absent python
install_pkg_if_absent ansible
install_pkg_if_absent reattach-to-user-namespace
install_pkg_if_absent the_silver_searcher
install_pkg_if_absent go

# Make zsh default shell
function update_shell() {
  local shell_path;
  shell_path="$(which zsh)"

  fancy_echo "Changing default shell to zsh ..."
  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    fancy_echo "Adding '$shell_path' to /etc/shells"
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi

  chsh -s "$shell_path"
  source ~/.zshrc
}

case "$SHELL" in
  */zsh)
    if [ "$(which zsh)" != '/usr/local/bin/zsh' ] ; then
      update_shell
    fi
    ;;
  *)
    update_shell
    ;;
esac

fancy_echo "Adding python neovim support..."
if ! pip2 show neovim > /dev/null 2>&1; then
  pip2 install --upgrade neovim
fi


if ! pip3 show neovim > /dev/null 2>&1; then
  pip3 install --upgrade neovim
fi

# Install vim-plug
fancy_echo "Installing vim-plug..."
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install vim plugins
fancy_echo "Install vim plugins..."
vim +PlugInstall +qall

# Install Brew Cask to make app installation easy
fancy_echo "Tapping cask..."
brew tap homebrew/cask

function install_app_if_absent() {
  local pkg="$1"

  fancy_echo "Checking if app $pkg exists..."
  if ! brew cask ls --versions $pkg > /dev/null 2>&1; then
    fancy_echo "Installing $pkg..."
    brew cask install --force "$pkg"
  fi
}

# Install apps
install_app_if_absent google-chrome
install_app_if_absent spectacle
install_app_if_absent docker
install_app_if_absent firefox
install_app_if_absent sourcetree
install_app_if_absent iterm2
install_app_if_absent slack
install_app_if_absent java
install_app_if_absent intellij-idea-ce
install_app_if_absent vagrant

source /usr/local/opt/chruby/share/chruby/chruby.sh
chruby 2.5.1
# Install recent ruby version
if [ ! -d "$HOME/.rubies/ruby-2.5.1" ]; then
  fancy_echo "Installing Ruby 2.5.1..."
  ruby-install ruby-2.5.1
fi

function install_gem_if_absent() {
  local pkg="$1"

  fancy_echo "Checking if gem $pkg exists..."
  if ! gem list -i $pkg > /dev/null 2>&1; then
    fancy_echo "Installing $pkg..."
    gem install neovim
  fi
}

# Install gems
install_gem_if_absent "neovim"

# Install nvm
fancy_echo "Checking if nvm and node exists..."
if command -v nvm > /dev/null 2>&1; then
  unset NVM_DIR
  fancy_echo "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

  # Install node
  fancy_echo "Install Node..."
  nvm install node
fi

function install_npm_pkg_if_absent() {
  local pkg="$1"

  fancy_echo "Checking if npm package $pkg exists..."
  if ! npm list -g $pkg > /dev/null 2>&1; then
    fancy_echo "Installing $pkg..."
    npm i -g $pkg
  fi
}

# Install npm packages
install_npm_pkg_if_absent neovim
install_npm_pkg_if_absent tern
install_npm_pkg_if_absent yarn
install_npm_pkg_if_absent prettier

fancy_echo "SUCCESS! Enjoy your new setup!"
exit 0
