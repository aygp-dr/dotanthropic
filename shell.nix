{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Core tools only for testing
    git
    curl
    gnumake
  ];

  shellHook = ''
    export ANTHROPIC_HOME="$HOME/.anthropic"
    echo "Nix shell initialized with basic tools"
    echo "Git version: $(git --version)"
  '';
}