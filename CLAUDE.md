# Project setup conventions

This system is NixOS (unstable, 25.11+) with an RTX 5070 Ti for local LLM
work via Ollama on the host (http://localhost:11434). Apply these conventions
to every project unless I explicitly override them.

## Environment management

- Use a `flake.nix` with a `devShell` for all project dependencies. Never
  install Python packages, Node packages, or system tools globally.
- Pin `nixpkgs` to `nixos-unstable` in flake inputs.
- Set `config.allowUnfree = true` in the flake. Add `config.cudaSupport = true`
  only if the project itself runs CUDA workloads in-shell (not if it just
  calls Ollama on the host).
- Always include a `flake.lock` and commit it.
- Provide a `shellHook` that prints language versions and confirms reachability
  of any external services the project depends on (Ollama, Anthropic API key
  presence, etc.).

## Working directory conventions

All agent-driven projects live under `/mnt/ai_mod/projects/`. This is a
deliberate boundary: agent work happens here, not in `/home/nbk/`. If a
task seems to require touching files outside the project root, stop and
ask — that's a signal something's gone wrong with the scope, not a hint
that you should reach further.

Exceptions:
- Reading from `~/.config/<project>/env` for secrets is fine.
- Reading from `/mnt/ai_mod/ollama/` for local model weights is fine
  (read-only — Ollama manages this directory).
- Anything else outside `/mnt/ai_mod/projects/<this-project>/` requires
  explicit confirmation.

## Python projects

- Use `uv` as the package manager. Not pip directly, not poetry.
- The flake provides Python itself + `uv` + system tooling. `uv` manages the
  application's Python deps inside the project via `pyproject.toml` and
  `uv.lock`. Both committed.
- Prefer `uv run <cmd>` over activating venvs manually.

## Sandboxing for agent execution

- Code that *I* run (orchestration, glue, scripts): runs directly in the dev
  shell, no isolation needed.
- Code that *agents* generate or execute (tool calls, shell commands, test
  runs): must be sandboxed. Default to `bubblewrap` for one-shot commands,
  `git worktree` + container for per-task workspaces, Docker when the agent
  harness (e.g., OpenHands) requires it.
- Never let an agent execute commands with access to `$HOME` outside the
  project root, the global Nix store (read-only is fine), or the network
  beyond explicitly whitelisted hosts.

## Secrets

- API keys (Anthropic, OpenAI, etc.) live in `~/.config/<project>/env` or
  via 1Password CLI (`op read`). Never in the repo, never in the flake,
  never in shell history.
- The flake's `shellHook` should source the env file if present and warn
  if a required key is missing.

## Git workflow

Initialise the repo on first run if one doesn't exist. Make a commit at
every meaningful checkpoint — not at the end of the session, throughout it.

A "meaningful checkpoint" is roughly:
- After project scaffolding lands (flake, pyproject, directory structure)
- After each module is implemented and parses cleanly
- After tests for a module pass
- After each acceptance criterion is met
- Before any non-trivial refactor of code I might want to revert

Commit messages should be informative and follow conventional commit style
(feat:, fix:, refactor:, test:, chore:, docs:). Body should explain *why*
the change was made when that isn't obvious from the diff. One-line
messages are fine for trivial changes.

Don't squash, don't rebase, don't force-push. Linear history with frequent
small commits is the goal — I want to be able to read the log and understand
the trajectory of the work.

Don't commit secrets, the .env file, or anything in .gitignore. Don't
configure a remote — local commits only for now.

If a change feels ambiguous or you're making an architectural choice with
real consequences, mention that in the commit body so I can find it later.

## Repo hygiene

- `.envrc` with `use flake` for direnv users (assume yes).
- `.gitignore` excludes `.direnv/`, `result`, `result-*`, `__pycache__/`,
  `.venv/`, `node_modules/`, `*.log`, and any project-specific data dirs
  (e.g. `models/`, `outputs/`).
- README starts with: prereqs (NixOS or Nix with flakes), how to enter the
  dev shell, how to run the thing, where secrets go.

## What to do when starting a new project

1. Create the flake first, before any code.
2. Verify `nix develop` works and the shellHook output is correct.
3. Initialise git, add `.envrc` and `.gitignore`.
4. Then start writing code.

## What to push back on

If I ask you to do something that violates these conventions (install
something globally, skip the flake, hardcode a secret, run agent-generated
code without sandboxing), tell me and ask for confirmation before proceeding.
Don't silently work around the conventions.

## When stuck, question the design

If you hit rate limits, timeouts, memory pressure, or repeated failures:
after one workaround attempt, stop and reconsider the approach before
iterating further. Constraints are usually information about the design,
not obstacles to engineer around. Surface what you're seeing and why
before continuing — one good question beats fifteen minutes of escalating
workarounds.

Avoid: increasing timeouts beyond reason, retry-with-bigger-numbers,
weakening tests to pass, catching-and-ignoring exceptions, sleeps to
dodge rate limits.

## Cost awareness

Pause and confirm the approach before any operation likely to exceed
~5 minutes wall clock or ~50K tokens. Long autonomous work is fine
when the plan is solid; expensive when it isn't.

## Security review checklist for web features

Before completing any web feature implementation, verify these security
properties:

### Authorization (CRITICAL)

- Every route handler that reads data MUST verify the current user owns
  or has explicit share access to the resource. Never return data for a
  slug/ID without checking ownership.
- Every route handler that mutates data MUST verify ownership (not merely
  share access).
- Admin-only routes MUST gate on a checked admin role. Never trust that
  "authenticated" implies "authorized".
- Index/list endpoints MUST scope queries to the authenticated user — never
  return all records across users to non-admins.

### CSRF

- Every `<form method="post">` MUST contain a CSRF token hidden field.
- HTMX or AJAX POST requests MUST send the CSRF token via a header.

### SSRF

- Any user-supplied URL that will be fetched server-side MUST be validated
  against a blocklist of private/link-local/metadata IPs before the
  request is made.
- Do not trust URL schemes — only allow http/https.
- Resolve the hostname and check the resulting IP, not just the hostname
  string.

### Output sanitization

- AI-generated or user-supplied content rendered as HTML MUST pass through
  an HTML sanitizer (e.g., nh3, bleach) with an explicit allowlist of safe
  tags/attributes.
- Filenames in Content-Disposition headers MUST be sanitized to
  alphanumeric, hyphen, underscore, and dot only.
- User-controlled strings outside template auto-escaping MUST be manually
  HTML-escaped.

### Resource protection

- Session secrets must never use default/hardcoded values in production.
  Refuse to start if unconfigured.
- File uploads must be size-limited.
- Expensive operations (LLM API calls) should be rate-limited per user.

### Mental model

Every route is accessible by any authenticated user unless you explicitly
check ownership. "Authenticated" does not mean "authorized". An attacker
who signs up legitimately can reach every non-public endpoint.
