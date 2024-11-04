#!/bin/bash

# Update package lists
sudo apt-get update

# Install essential packages
sudo apt-get install \
    git jq curl make gcc \
    emacs imagemagick \
    netcat openssl openssh-client \
    awscli coreutils sed gawk bash gnupg wget \
    zsh python3-venv python3-pip \
    davfs2 \
    clojure default-jdk \
    guile-3.0 \
    mailutils \
    texinfo \
    libgif-dev libjpeg-dev libpng-dev libtiff-dev \
    libxpm-dev libmagickwand-dev libgnutls28-dev \
    libgtk-3-dev librsvg2-dev libharfbuzz-dev \
    libwebp-dev

# Install Poetry
pip3 install poetry

# Add Poetry to PATH in .zshrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install fzf
sudo apt-get install fzf

# Switch to Zsh
# chsh -s $(which zsh)

# cd ~/opt/emacs-29.4/
# ./configure --with-x-toolkit=gtk3 --with-gnutls --with-imagemagick
# make bootstrap 
