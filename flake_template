{
  description = "PROJECT_DESCRIPTION_HERE";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            # Set to true ONLY if this project runs CUDA in-shell.
            # Leave false if you only call Ollama on the host.
            cudaSupport = false;
          };
        };

        # Python version — bump as needed per project.
        python = pkgs.python312;

        # Path to optional per-project env file with secrets.
        # Format: KEY=value, one per line. Sourced by shellHook if present.
        envFile = "$HOME/.config/PROJECT_NAME_HERE/env";
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Python + package manager
            python
            uv

            # Core CLI tooling
            git
            ripgrep
            jq
            fd
            curl

            # Agent / dev tooling
            # claude-code        # Uncomment when packaged in nixpkgs
            # gh                 # GitHub CLI, if needed for the project
          ];

          shellHook = ''
            echo ""
            echo "─── ${self.description or "Dev shell"} ───"
            echo "Python:   $(python --version 2>&1)"
            echo "uv:       $(uv --version 2>&1)"

            # Source secrets file if present.
            if [ -f "${envFile}" ]; then
              set -a
              source "${envFile}"
              set +a
              echo "Secrets:  loaded from ${envFile}"
            else
              echo "Secrets:  no env file at ${envFile} (create if needed)"
            fi

            # Service reachability checks.
            # Ollama on host:
            if curl -fsS --max-time 1 http://localhost:11434/api/version >/dev/null 2>&1; then
              ver=$(curl -fsS http://localhost:11434/api/version | jq -r .version)
              echo "Ollama:   reachable (v$ver) at localhost:11434"
            else
              echo "Ollama:   not reachable at localhost:11434"
            fi

            # Anthropic API key check (only warns, doesn't fail).
            if [ -n "''${ANTHROPIC_API_KEY:-}" ]; then
              echo "Claude:   ANTHROPIC_API_KEY is set"
            else
              echo "Claude:   ANTHROPIC_API_KEY not set (export or add to env file)"
            fi

            echo ""

            # Make uv use the project's .venv inside the project, not global cache.
            export UV_PROJECT_ENVIRONMENT="$PWD/.venv"
          '';
        };
      });
}
