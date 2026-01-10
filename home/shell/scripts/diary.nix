{
  pkgs,
}: let
  diaryCmd = "diary";

  diary = pkgs.writeShellApplication {
    name = diaryCmd;

    runtimeInputs = with pkgs; [coreutils fzf gnupg];

    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      DIARY_DIR="''${DIARY_DIR:-$HOME/Documents/log}"
      EDITOR_BIN="''${EDITOR:-vi}"

      mkdir -p "$DIARY_DIR"
      chmod 700 "$DIARY_DIR"

      today_file() {
        date +"%Y-%m-%d".md.gpg
      }

      today_header() {
        date +"%A, %d %B %Y"
      }

      gpg_recipient() {
        if [[ -n "''${GPG_RECIPIENT:-}" ]]; then
          printf '%s\n' "$GPG_RECIPIENT"
          return 0
        fi

        local rec
        rec="$(gpg --list-secret-keys --with-colons 2>/dev/null | awk -F: '$1=="sec"{print $5; exit}')"
        if [[ -z "$rec" ]]; then
          echo "No GPG secret key found. Set GPG_RECIPIENT to your key id or email." >&2
          exit 1
        fi

        printf '%s\n' "$rec"
      }

      ensure_today_exists() {
        local f
        f="$DIARY_DIR/$(today_file)"

        if [[ ! -f "$f" ]]; then
          printf "# %s\n\n" "$(today_header)" \
            | gpg --quiet --encrypt --recipient "$(gpg_recipient)" --output "$f"
          return 0
        fi

        local tmp
        tmp="$(mktemp)"
        trap 'rm -f "$tmp"' RETURN

        gpg --quiet --decrypt "$f" > "$tmp"

        local first
        first="$(head -n 1 "$tmp" || true)"
        local desired
        desired="# $(today_header)"

        if [[ "$first" != "$desired" ]]; then
          { printf "%s\n\n" "$desired"; cat "$tmp"; } > "''${tmp}.new"
          mv "''${tmp}.new" "$tmp"
          gpg --quiet --yes --encrypt --recipient "$(gpg_recipient)" --output "$f" "$tmp"
        fi

        rm -f "$tmp"
        trap - RETURN
      }

      edit_file() {
        local f="$1"
        local tmp
        tmp="$(mktemp)"
        trap 'rm -f "$tmp"' RETURN

        if [[ -f "$f" ]]; then
          gpg --quiet --decrypt "$f" > "$tmp"
        fi

        "$EDITOR_BIN" "$tmp"

        gpg --quiet --yes --encrypt --recipient "$(gpg_recipient)" --output "$f" "$tmp"

        rm -f "$tmp"
        trap - RETURN
      }

      cmd_today() {
        ensure_today_exists
        edit_file "$DIARY_DIR/$(today_file)"
      }

      cmd_browse() {
        local files=()
        while IFS= read -r f; do
          files+=("$f")
        done < <(find "$DIARY_DIR" -maxdepth 1 -type f -name "*.gpg" -print)
        if [[ ''${#files[@]} -eq 0 ]]; then
          echo "No entries yet in $DIARY_DIR"
          exit 0
        fi

        local chosen=""
        if command -v fzf >/dev/null 2>&1; then
          chosen="$(
            printf '%s\n' "''${files[@]}" \
              | sed "s|^$DIARY_DIR/||" \
              | fzf --prompt="Diary date > "
          )" || exit 0
          chosen="$DIARY_DIR/$chosen"
        else
          echo "Available entries:"
          printf '%s\n' "''${files[@]}" | sed "s|^$DIARY_DIR/||"
          echo
          read -r -p "Type filename to open: " chosen
          chosen="$DIARY_DIR/$chosen"
        fi

        [[ -f "$chosen" ]] || { echo "Not found: $chosen"; exit 1; }
        edit_file "$chosen"
      }

      usage() {
        cat <<EOF
      Usage: diary <command>

      Commands:
        today        Create/open today's encrypted entry in \$EDITOR
        browse       Browse existing entries and open one
      EOF
      }

      main() {
        local cmd="''${1:-}"
        case "$cmd" in
          today)  cmd_today ;;
          browse) cmd_browse ;;
          ""|-h|--help) usage ;;
          *) echo "Unknown command: $cmd"; usage; exit 2 ;;
        esac
      }

      main "$@"
    '';
  };
in {
  cmds = [diary];
}
