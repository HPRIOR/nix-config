{
  config,
  lib,
  ...
}: let
  cfg = config.my.features;
in {
  config = lib.mkMerge [
    (lib.mkIf cfg.aiTools.enable {
      home.file."${config.my.paths.configDir}/aichat/config.yaml".text = ''
        model: openai
        clients:
        - type: openai
          models:
              - name: gpt-5.2
                max_input_tokens: 400000
                max_output_tokens: 128000
                input_price: 1.75
                output_price: 14
                supports_vision: true
                supports_function_calling: true
              - name: gpt-5
                max_input_tokens: 400000
                max_output_tokens: 128000
                input_price: 1.25
                output_price: 10
                supports_vision: true
                supports_function_calling: true
              - name: gpt-5-mini
                max_input_tokens: 400000
                max_output_tokens: 128000
                input_price: 0.25
                output_price: 2
                supports_vision: true
                supports_function_calling: true
              - name: gpt-5-nano
                max_input_tokens: 400000
                max_output_tokens: 128000
                input_price: 0.05
                output_price: 0.4
                supports_vision: true
                supports_function_calling: true
      '';

      home.file."${config.my.identity.homeDir}/.claude/commands/fix-github-issue.md".text = ''
        Please analyze and fix the GitHub issue: $ARGUMENTS.

        Follow these steps:

        1. Use `gh issue view` to get the issue details
        2. Understand the problem described in the issue
        3. Search the codebase for relevant files
        4. Implement the necessary changes to fix the issue
        5. Write and run tests to verify the fix
        6. Ensure code passes linting and type checking
        7. Create a descriptive commit message
        8. Push and create a PR

        Remember to use the GitHub CLI (`gh`) for all GitHub-related tasks.
      '';
    })

    (lib.mkIf cfg.codeSyncFiles.enable {
      home.file."${config.my.identity.homeDir}/Code/.stignore".text = ''
        !**/.envrc
        !**/.direnv
        !**/.git
        !**/.gitignore
        !**/.ocamlformat
        !**/.claude
        // ignore all hidden files, except for the above
        (?d)**/.*

        // mac
        (?d).DS_Store

        // Dotnet
        (?d)**/obj/
        (?d)**/bin/
        (?d)**/node_modules/

        // Ocaml
        (?d)**/_build/
        (?d)**/_opam/
        (?d)**/.opam/
        (?d)**/.opam-switch/

        // Rust
        (?d)**/target/
        // (?d)Cargo.lock
        (?d)**/*.rs.bk

        (?d)**/venv/
        (?d)**/.idea/

        // Scala
        (?d)**/.metals
        (?d)**/.bloop

        // Android
        (?d)**/.android
      '';
    })
  ];
}
