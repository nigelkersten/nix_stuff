#!/usr/bin/env fish

# install.fish — symlink this repo's contents into ~/.claude/

set repo (realpath (dirname (status --current-filename)))

echo "Installing Claude config from: $repo"
echo ""

mkdir -p ~/.claude

# Top-level files
for file in CLAUDE.md
    if test -f $repo/$file
        ln -sfn $repo/$file ~/.claude/$file
        echo "  ~/.claude/$file → $repo/$file"
    end
end

# Directories — must remove existing dir/symlink first to avoid
# the "ln descends into target" trap
for dir in templates prompts
    if test -d $repo/$dir
        # Remove existing target if it's a real directory or stale symlink
        if test -L ~/.claude/$dir
            rm ~/.claude/$dir
        else if test -d ~/.claude/$dir
            # Real directory exists — refuse to clobber unless empty
            if test (count (ls -A ~/.claude/$dir 2>/dev/null)) -eq 0
                rmdir ~/.claude/$dir
            else
                echo "  WARNING: ~/.claude/$dir is a non-empty directory."
                echo "  Refusing to overwrite. Move its contents into $repo/$dir, then remove ~/.claude/$dir manually and re-run."
                continue
            end
        end
        ln -sfn $repo/$dir ~/.claude/$dir
        echo "  ~/.claude/$dir → $repo/$dir"
    end
end

echo ""
echo "Done."
