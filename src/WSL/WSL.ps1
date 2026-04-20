wsl -d Ubuntu -u root sh -c "apt-get update && apt-get install -y curl xz-utils";
wsl -d Ubuntu sh -c "curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --no-daemon";
wsl sh -c "git config --global include.path /mnt/c/Users/$env:USERNAME/.gitconfig";