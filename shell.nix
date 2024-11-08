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
  name = "dotanthropic";
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
    pdftops

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
    bash-completion
    direnv

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

    source ${pkgs.bash-completion}/etc/profile.d/bash_completion.sh

    eval "$(direnv hook bash)"

    # Set up environment marker with date, username, host, and path
    export PS1="\n\[\033[1;35m\](dotanthropic)\[\033[0m\] \[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\] \$ "
    export PATH="$HOME/.anthropic/tools/bin:$PATH"

    export PATH="$(brew --prefix)/bin:$PATH"
    export PATH="/usr/local/bin:$PATH" 

    echo "🚀 dotanthropic environment activated"
  '';
}
