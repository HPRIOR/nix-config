# Repository Guidelines

## Project Structure & Module Organization
- `flake.nix`: Flake inputs/outputs; wires NixOS, darwin, and Home Manager via `utils/mkSystem.nix`.
- `hosts/desktop|mac`: System modules plus host-specific Home Manager configs.
- `home/`: Shared user modules (shell, terminal, UI, Vim) composed into host configs.
- `overlays/`: Custom package overlays (`claude.nix`, `codex.nix`, `citrix.nix`) layered onto `nixpkgs`.
- `secrets/`: SOPS-managed data; never store plain secrets elsewhere.
- `utils/`: Helpers for constructing systems; avoid duplicating logic found here.

## Build, Test, and Development Commands
- Linux: `sudo nixos-rebuild switch --flake ~/.nix-config#nixos` (apply system + Home Manager).
- macOS: `darwin-rebuild switch --flake ~/.nix-config#Harrys-MacBook-Pro` (or `#Harrys-MacBook-Air`).
- Dry-run before changes: `nixos-rebuild dry-run --flake ~/.nix-config#nixos` or `darwin-rebuild check --flake ...`.
- Flake sanity: `nix flake check` to ensure outputs evaluate; `nix flake show` to confirm targets.
- Quick tool bootstrap: `nix-shell -p git neovim` if you lack base tools on a fresh system.

## Coding Style & Naming Conventions
- Nix files use two-space indentation, trailing semicolons for attributes, and explicit `inherit` to reduce repetition.
- Prefer small, composable modules under `home/` and `hosts/`; keep host-specific logic in host files, not shared modules.
- Overlays: keep one overlay per concern; name packages clearly (`claude`, `codex`, etc.).
- Comments: add short, purpose-driven notes only where logic is non-obvious (e.g., workarounds, insecure packages).

## Testing Guidelines
- For config changes, run the appropriate `*rebuild * --flake ...` with `dry-run`/`check` first, then `switch`.
- Validate overlays by building the affected package: `nix build .#packages.x86_64-linux.<name>` or `.#packages.aarch64-darwin.<name>`.
- When touching secrets, ensure `sops` decrypts correctly and that `secrets/secrets.yaml` stays encrypted in git.

## Commit & Pull Request Guidelines
- Commit messages follow concise sentence case with a trailing period (`Add focus history daemon.`); group related changes per commit.
- Describe scope in the subject; add brief body bullets for risky changes (e.g., kernel flags, service toggles).
- PRs should include: purpose, impacted hosts (`nixos`, `Harrys-MacBook-Pro`, etc.), test commands run, and any screenshots/logs for UI tweaks.
- Keep changes minimal and revertable; prefer adding new modules over editing shared ones unless necessary.

## Security & Configuration Tips
- SOPS keys live at `/etc/sops/age/keys.txt`; confirm access before applying secrets-dependent builds.
- Avoid committing machine-local artifacts (`result`, `hardware-configuration.nix` backups) and keep `secrets/` encrypted at rest.
