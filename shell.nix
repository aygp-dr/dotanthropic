{ pkgs ? import <nixpkgs> { } }:

let
  pythonEnv = pkgs.python311.withPackages (ps: with ps; [
    anthropic
    requests
    streamlit
    pip
    virtualenv
    psutil
    psycopg2
    watchdog
    boto3
    poetry-core
  ]);
in
pkgs.mkShell {
  name = "tools";
  buildInputs = with pkgs; [
    # Python environment
    pythonEnv
    poetry

    # Core tools
    git
    jq
    curl
    gnumake

    # Editors and Development tools
    emacs
    imagemagick

    # Network tools
    netcat
    openssl
    openssh

    # AWS tools
    awscli

    # System tools
    coreutils
    gnused
    gawk
    bash

    # Security tools
    gnupg
  ];

  shellHook = ''
    # Ensure TMPDIR is set
    export TMPDIR="/tmp"

    # Ensure directories exist
    mkdir -p $HOME/.anthropic/{tools,backups,journal,sandbox,docs}
    mkdir -p $HOME/.anthropic/journal/screenshots/$(date +%Y-%m-%d)

    # Prioritize BSD wrappers and coreutils in PATH
    export PATH="${pkgs.coreutils}/bin:$PATH" 

    # Set up environment marker with date, username, host, and path
    export PS1="\n\[\033[1;35m\](tools)\[\033[0m\] \[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\] \$ "
    export PATH="$HOME/.anthropic/tools/bin:$PATH"

    echo "🚀 Tools environment activated"
  '';
}
