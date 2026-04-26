---
name: nix-cli-tools
description: Use whenever Codex needs to run a CLI tool or shell command for local work, especially if the command may be missing from PATH. Provides a default policy for checking existing tools, using project Nix environments, transiently accessing tools with `nix shell nixpkgs#PACKAGE -c COMMAND`, searching nixpkgs, and gathering lightweight Nix/system/hardware context before using Nix-provided tools. Avoid persistent installs unless explicitly requested.
---

# Nix CLI Tools

## Overview

Use Nix as the default fallback for local CLI tools that are not already installed. Prefer transient tool access and project-provided environments over persistent installation.

## Workflow

1. Before running a CLI command, check whether the command already exists when practical:
   - Use `command -v <tool>`.
   - If the tool is present, use it normally.
   - If the tool is missing, use transient Nix access.

2. Prefer project-local Nix context:
   - If the repo has `flake.nix`, inspect it before choosing a package.
   - Prefer `nix develop -c <command>` when the project dev shell likely provides the tool.
   - Otherwise use `nix shell nixpkgs#<package> -c <command>`.

3. Before the first transient Nix tool invocation in a turn or session, perform a lightweight preflight:
   - `nix --version`
   - `uname -a`
   - Check whether the current project has `flake.nix`.
   - Run `nix flake show` only when it is relevant to selecting or using a tool.
   - Gather hardware or system context only when it affects package choice or command behavior.
   - Do not collect sensitive information unnecessarily.

4. For missing tools:
   - Infer the likely nixpkgs package name.
   - If unclear, search with `nix search nixpkgs <query>`.
   - Run the command transiently with `nix shell nixpkgs#<package> -c <command>`.
   - Do not use `nix-env` unless the user explicitly asks for persistent installation.

5. If sandboxing blocks Nix daemon, store, cache, or network access:
   - Rerun the same Nix command with escalation.
   - Explain that Nix daemon or network/cache access is required.

6. After using a transient tool, do not assume it is now installed globally.
   - If relevant, verify with `command -v <tool>`.

## Examples

- Missing formatter:

  ```bash
  command -v taplo || nix shell nixpkgs#taplo -c taplo fmt ...
  ```

- Missing JSON tool:

  ```bash
  nix shell nixpkgs#jq -c jq ...
  ```

- Missing media or conversion tool:

  ```bash
  nix shell nixpkgs#imagemagick -c magick ...
  ```

- Package search:

  ```bash
  nix search nixpkgs ripgrep
  ```

- Project dev shell:

  ```bash
  nix develop -c cargo test
  ```

## Do Not

- Do not install packages persistently with `nix-env` unless explicitly requested.
- Do not edit `flake.nix`, `flake.lock`, profiles, or system config unless required by the user task.
- Do not run broad hardware inventory commands unless relevant.
- Do not replace simple built-in shell commands unnecessarily.
