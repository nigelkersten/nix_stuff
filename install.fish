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

