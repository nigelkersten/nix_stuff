# install.fish in repo root
#!/usr/bin/env fish

set repo (dirname (status --current-filename))
set repo (realpath $repo)

echo "Installing from $repo"

# Claude Code
mkdir -p ~/.claude
ln -sf $repo/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf $repo/templates ~/.claude/templates
echo "  ~/.claude → $repo"

# NixOS — needs sudo
if test -L /etc/nixos/configuration.nix
  echo "  /etc/nixos/configuration.nix already a symlink, skipping"
else
  echo "  Backing up /etc/nixos/configuration.nix → .bak"
  sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak
  sudo ln -sf $repo/configuration.nix /etc/nixos/configuration.nix
  echo "  /etc/nixos/configuration.nix → $repo/configuration.nix"
end

echo "Done. Run 'sudo nixos-rebuild switch' to apply NixOS changes."
