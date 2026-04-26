{
  config,
  lib,
  pkgs,
  settings,
  ...
}: let
  codexHome = "${settings.homeDir}/.codex";
  agentsHome = "${settings.homeDir}/.agents";
  managedConfigText =
    builtins.replaceStrings
    ["/etc/codex/skills" "/etc/codex"]
    ["${agentsHome}/skills" codexHome]
    (builtins.readFile ./config.toml);
  managedConfigFile = pkgs.writeText "codex-config.nix-managed.toml" managedConfigText;
  managedRulesFile = pkgs.writeText "codex-rules.nix-managed.rules" (builtins.readFile ./rules/default.rules);
  configPath = "${codexHome}/config.toml";
  rulesPath = "${codexHome}/rules/default.rules";
  managedConfigBlockStart = "# BEGIN nix-managed-codex";
  managedConfigBlockEnd = "# END nix-managed-codex";
  managedRulesBlockStart = "# BEGIN nix-managed-codex-rules";
  managedRulesBlockEnd = "# END nix-managed-codex-rules";
in {
  home.file = {
    ".codex/config.nix-managed.toml".text = managedConfigText;

    ".codex/agents/code-style.toml".source = ./agents/code-style.toml;
    ".codex/agents/rust-engineer.toml".source = ./agents/rust-engineer.toml;
    ".codex/agents/docs-researcher.toml".source = ./agents/docs-researcher.toml;
    ".codex/agents/performance-reviewer.toml".source = ./agents/performance-reviewer.toml;
    ".codex/agents/rust-bevy-reviewer.toml".source = ./agents/rust-bevy-reviewer.toml;

    ".agents/skills/nix-cli-tools" = {
      source = ./skills/nix-cli-tools;
      force = true;
    };
  };

  # Codex mutates ~/.codex/config.toml for project trust and UI state, so Home
  # Manager only owns a marked block and preserves the rest of the file.
  home.activation.codexConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    codex_dir=${lib.escapeShellArg codexHome}
    config_file=${lib.escapeShellArg configPath}
    managed_file=${lib.escapeShellArg managedConfigFile}
    block_start=${lib.escapeShellArg managedConfigBlockStart}
    block_end=${lib.escapeShellArg managedConfigBlockEnd}

    $DRY_RUN_CMD mkdir -p "$codex_dir"

    tmp_file="$(${pkgs.coreutils}/bin/mktemp)"
    next_file="$(${pkgs.coreutils}/bin/mktemp)"

    if [ -f "$config_file" ]; then
      ${pkgs.gawk}/bin/awk \
        -v start="$block_start" \
        -v end="$block_end" \
        '$0 == start { skip = 1; next } $0 == end { skip = 0; next } !skip { print }' \
        "$config_file" > "$tmp_file"
    else
      : > "$tmp_file"
    fi

    ${pkgs.gawk}/bin/awk \
      -v start="$block_start" \
      -v end="$block_end" \
      -v managed="$managed_file" '
        function print_managed() {
          if (inserted) {
            return
          }
          if (printed_any) {
            print ""
          }
          print start
          while ((getline line < managed) > 0) {
            print line
          }
          close(managed)
          print end
          print ""
          inserted = 1
        }

        /^[[:space:]]*\[\[/ || /^[[:space:]]*\[/ {
          print_managed()
        }

        {
          print
          printed_any = 1
        }

        END {
          if (!inserted) {
            print_managed()
          }
        }
      ' "$tmp_file" > "$next_file"

    $DRY_RUN_CMD install -m 0600 "$next_file" "$config_file"
    rm -f "$tmp_file" "$next_file"
  '';

  # Codex stores accepted command approvals in ~/.codex/rules/default.rules, so
  # Home Manager merges the managed policy into that active file instead of
  # replacing it or writing a separate rules file that Codex may not load.
  home.activation.codexRules = lib.hm.dag.entryAfter ["writeBoundary"] ''
    rules_dir=${lib.escapeShellArg "${codexHome}/rules"}
    rules_file=${lib.escapeShellArg rulesPath}
    managed_file=${lib.escapeShellArg managedRulesFile}
    block_start=${lib.escapeShellArg managedRulesBlockStart}
    block_end=${lib.escapeShellArg managedRulesBlockEnd}

    $DRY_RUN_CMD mkdir -p "$rules_dir"

    tmp_file="$(${pkgs.coreutils}/bin/mktemp)"
    next_file="$(${pkgs.coreutils}/bin/mktemp)"

    if [ -f "$rules_file" ]; then
      ${pkgs.gawk}/bin/awk \
        -v start="$block_start" \
        -v end="$block_end" \
        '$0 == start { skip = 1; next } $0 == end { skip = 0; next } !skip { print }' \
        "$rules_file" > "$tmp_file"
    else
      : > "$tmp_file"
    fi

    {
      cat "$tmp_file"
      if [ -s "$tmp_file" ]; then
        printf '\n'
      fi
      printf '%s\n' "$block_start"
      cat "$managed_file"
      printf '%s\n' "$block_end"
    } > "$next_file"

    $DRY_RUN_CMD install -m 0644 "$next_file" "$rules_file"
    rm -f "$tmp_file" "$next_file"
  '';
}
