#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
import tempfile
import termios
import tty
from dataclasses import dataclass
from pathlib import Path


MODEL = "openai:gpt-5-mini"


@dataclass
class ChangeUnit:
    unit_id: str
    file_path: str
    kind: str
    summary: str
    patch: str


class LzcError(RuntimeError):
    pass


def run(
    args: list[str],
    *,
    check: bool = True,
    capture_output: bool = False,
    input_text: str | None = None,
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        args,
        check=check,
        text=True,
        input=input_text,
        capture_output=capture_output,
    )


def git_output(*args: str) -> str:
    return run(["git", *args], capture_output=True).stdout


def has_head() -> bool:
    return run(["git", "rev-parse", "--verify", "HEAD"], check=False, capture_output=True).returncode == 0


def ensure_git_repo() -> None:
    if run(
        ["git", "rev-parse", "--is-inside-work-tree"],
        check=False,
        capture_output=True,
    ).returncode != 0:
        raise LzcError("You are not inside a Git repository.")


def has_committable_changes() -> bool:
    if run(["git", "diff", "--quiet", "--", "."], check=False).returncode != 0:
        return True
    if run(["git", "diff", "--cached", "--quiet", "--", "."], check=False).returncode != 0:
        return True
    return False


def untracked_files() -> list[str]:
    output = git_output("ls-files", "--others", "--exclude-standard").strip()
    if not output:
        return []
    return output.splitlines()


def print_untracked_warning() -> None:
    if untracked_files():
        print("Warning: untracked files are ignored unless you stage them first.")


def write_commit_context() -> str:
    staged_diff = git_output("diff", "--cached", "--find-renames", "--relative", "--no-ext-diff", "--", ".")
    unstaged_diff = git_output("diff", "--find-renames", "--relative", "--no-ext-diff", "--", ".")

    parts = [
        "Git status:",
        git_output("status", "--short").rstrip(),
        "",
        "Staged diff:",
        staged_diff.rstrip() if staged_diff else "<none>",
        "",
        "Unstaged diff:",
        unstaged_diff.rstrip() if unstaged_diff else "<none>",
    ]
    return "\n".join(parts) + "\n"


def call_aichat(prompt: str, context: str) -> str:
    if shutil.which("aichat") is None:
        raise LzcError("aichat is not available in PATH.")

    result = run(
        ["aichat", "--model", MODEL, prompt],
        capture_output=True,
        input_text=context,
    )
    return result.stdout.strip()


def prompt_yes_no(message: str) -> bool:
    if not sys.stdin.isatty():
        response = input(message).strip().lower()
        print("")
        if response == "y":
            return True
        if response in ("", "n"):
            return False
        raise LzcError("Invalid response.")

    print(message, end="", flush=True)
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)

    try:
        tty.setraw(fd)
        while True:
            char = sys.stdin.read(1)
            if char in ("y", "Y"):
                print("y")
                return True
            if char in ("n", "N"):
                print("n")
                return False
            if char in ("\r", "\n", "\x1b"):
                print("")
                return False
            if char == "\x03":
                print("")
                raise KeyboardInterrupt
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)


def single_commit() -> None:
    print_untracked_warning()
    msg = call_aichat(
        "Write me a succinct git commit message for these changes. Follow sentence case and end with a trailing period. Return only the commit message.",
        write_commit_context(),
    )
    if not msg:
        raise LzcError("Failed to generate a commit message.")

    print(msg)
    if prompt_yes_no("Do you want to commit? (y/N): "):
        run(["git", "commit", "-am", msg])
        print("Committed!")
    else:
        print("Not committed")


def combined_diff() -> str:
    base_args = [
        "diff",
        "--binary",
        "--find-renames",
        "--relative",
        "--no-ext-diff",
        "--unified=0",
        "--inter-hunk-context=0",
    ]

    if has_head():
        return git_output(*base_args, "HEAD", "--", ".")
    return git_output(*base_args, "--cached", "--root", "--", ".")


def split_diff_into_units(diff_text: str) -> list[ChangeUnit]:
    units: list[ChangeUnit] = []
    unit_count = 0

    current_file = ""
    file_header: list[str] = []
    metadata_summary = ""
    hunk_header = ""
    hunk_body: list[str] = []
    in_file = False
    in_hunk = False
    saw_hunk = False

    def write_unit(kind: str, summary: str, body_lines: list[str]) -> None:
        nonlocal unit_count
        unit_count += 1
        units.append(
            ChangeUnit(
                unit_id=f"u{unit_count:03d}",
                file_path=current_file,
                kind=kind,
                summary=summary,
                patch="".join(file_header + body_lines),
            )
        )

    def flush_hunk() -> None:
        nonlocal in_hunk, hunk_header, hunk_body
        if not in_hunk:
            return
        summary = hunk_header.removeprefix("@@ ")
        write_unit("hunk", summary, hunk_body)
        in_hunk = False
        hunk_header = ""
        hunk_body = []

    def flush_file() -> None:
        nonlocal in_file, saw_hunk, current_file, file_header, metadata_summary
        flush_hunk()
        if not in_file:
            return
        if not saw_hunk:
            summary = metadata_summary or "metadata change"
            write_unit("file", summary, [])
        in_file = False
        saw_hunk = False
        current_file = ""
        file_header = []
        metadata_summary = ""

    for raw_line in diff_text.splitlines(keepends=True):
        if raw_line.startswith("diff --git "):
            flush_file()
            in_file = True
            saw_hunk = False
            file_header = [raw_line]
            metadata_summary = ""
            line = raw_line.rstrip("\n")
            current_file = line.removeprefix("diff --git a/").split(" b/", 1)[1]
            continue

        if not in_file:
            continue

        if raw_line.startswith("@@ "):
            flush_hunk()
            saw_hunk = True
            in_hunk = True
            hunk_header = raw_line.rstrip("\n")
            hunk_body = [raw_line]
            continue

        if raw_line.startswith("Binary files ") or raw_line.startswith("GIT binary patch"):
            if not metadata_summary:
                metadata_summary = "binary change"
            file_header.append(raw_line)
            continue

        if raw_line.startswith(
            (
                "rename from ",
                "rename to ",
                "copy from ",
                "copy to ",
                "new file mode ",
                "deleted file mode ",
                "similarity index ",
                "dissimilarity index ",
            )
        ):
            if not metadata_summary:
                metadata_summary = raw_line.rstrip("\n")
            if in_hunk:
                hunk_body.append(raw_line)
            else:
                file_header.append(raw_line)
            continue

        if in_hunk:
            hunk_body.append(raw_line)
        else:
            file_header.append(raw_line)

    flush_file()
    return units


def write_atomic_prompt(diff_text: str, units: list[ChangeUnit]) -> str:
    sections = [
        "Group the git change units below into atomic commits.",
        "",
        "Rules:",
        "- Group by logical intent, not by file path.",
        "- A single commit may include units from multiple files when they are one cohesive change.",
        "- Do not split tightly coupled implementation and follow-up fixes that should land together.",
        "- Every unit must appear exactly once.",
        "- Use concise sentence-case commit messages with a trailing period.",
        "- If the work is truly one concern, returning a single commit is allowed.",
        "",
        'Return only valid JSON in this shape:',
        '{"commits":[{"message":"Add atomic commit planning.","unit_ids":["u001","u002"]}]}',
        "",
        "Git status:",
        git_output("status", "--short").rstrip(),
        "",
        "Combined diff:",
        "```diff",
        diff_text.rstrip(),
        "```",
        "",
        "Change units:",
    ]

    for unit in units:
        sections.extend(
            [
                "",
                f"Unit {unit.unit_id}",
                f"Path: {unit.file_path}",
                f"Kind: {unit.kind}",
                f"Summary: {unit.summary}",
                "```diff",
                unit.patch.rstrip(),
                "```",
            ]
        )

    return "\n".join(sections) + "\n"


def parse_plan(raw_output: str) -> dict[str, object]:
    lines = [line for line in raw_output.splitlines() if not line.startswith("```")]
    cleaned = "\n".join(lines).strip()
    if not cleaned:
        raise LzcError("Model did not return a valid atomic commit plan.")
    try:
        plan = json.loads(cleaned)
    except json.JSONDecodeError as exc:
        raise LzcError("Model did not return a valid atomic commit plan.") from exc
    return plan


def validate_atomic_plan(plan: dict[str, object], units: list[ChangeUnit]) -> list[dict[str, object]]:
    commits = plan.get("commits")
    if not isinstance(commits, list) or not commits:
        raise LzcError("Model did not return a valid atomic commit plan.")

    unit_ids = {unit.unit_id for unit in units}
    planned_ids: list[str] = []

    for commit in commits:
        if not isinstance(commit, dict):
            raise LzcError("Model did not return a valid atomic commit plan.")
        message = commit.get("message")
        commit_unit_ids = commit.get("unit_ids")
        if not isinstance(message, str) or not message:
            raise LzcError("Model did not return a valid atomic commit plan.")
        if not isinstance(commit_unit_ids, list) or not commit_unit_ids:
            raise LzcError("Model did not return a valid atomic commit plan.")
        if not all(isinstance(unit_id, str) and unit_id for unit_id in commit_unit_ids):
            raise LzcError("Model did not return a valid atomic commit plan.")
        planned_ids.extend(commit_unit_ids)

    if len(planned_ids) != len(set(planned_ids)):
        raise LzcError("Atomic plan assigned the same change unit more than once.")
    if set(planned_ids) != unit_ids:
        raise LzcError("Atomic plan did not cover every change unit exactly once.")

    return commits


def preview_atomic_plan(commits: list[dict[str, object]], units: list[ChangeUnit]) -> None:
    unit_paths = {unit.unit_id: unit.file_path for unit in units}
    print("Proposed atomic commit plan:")

    for index, commit in enumerate(commits, start=1):
        unit_ids = commit["unit_ids"]
        files = sorted({unit_paths[unit_id] for unit_id in unit_ids})
        print(f"{index}. {commit['message']}")
        print(f"   {' '.join(files)}")


def reset_index_for_atomic() -> None:
    if has_head():
        run(["git", "reset", "--quiet"])
    else:
        run(["git", "rm", "-r", "--cached", "--quiet", "--ignore-unmatch", "."], check=False)


def apply_atomic_plan(commits: list[dict[str, object]], units: list[ChangeUnit]) -> None:
    with tempfile.TemporaryDirectory(prefix="lzc-atomic-") as tmpdir:
        tmpdir_path = Path(tmpdir)
        for unit in units:
            (tmpdir_path / f"{unit.unit_id}.patch").write_text(unit.patch, encoding="utf-8")

        reset_index_for_atomic()

        for index, commit in enumerate(commits, start=1):
            reset_index_for_atomic()
            for unit_id in commit["unit_ids"]:
                patch_path = tmpdir_path / f"{unit_id}.patch"
                result = run(
                    ["git", "apply", "--cached", "--recount", "--unidiff-zero", str(patch_path)],
                    check=False,
                )
                if result.returncode != 0:
                    raise LzcError(f"Failed to stage change unit {unit_id} for atomic commit {index}.")

            if run(["git", "diff", "--cached", "--quiet"], check=False).returncode == 0:
                raise LzcError(f"Atomic commit {index} did not stage any changes.")

            result = run(["git", "commit", "-m", commit["message"]], check=False)
            if result.returncode != 0:
                raise LzcError(f"Failed to create atomic commit {index}.")


def atomic_commit() -> None:
    print_untracked_warning()
    diff_text = combined_diff()
    if not diff_text.strip():
        raise LzcError("No tracked changes available for atomic commits.")

    units = split_diff_into_units(diff_text)
    if not units:
        raise LzcError("No change units were generated for atomic commits.")

    raw_plan = call_aichat(
        "Return only the JSON atomic commit plan.",
        write_atomic_prompt(diff_text, units),
    )
    commits = validate_atomic_plan(parse_plan(raw_plan), units)

    preview_atomic_plan(commits, units)
    if not prompt_yes_no("Do you want to create these atomic commits? (y/N): "):
        print("Not committed")
        return

    try:
        apply_atomic_plan(commits, units)
    except LzcError as exc:
        print("Atomic commit creation failed. Any commits already created are preserved in the current branch.")
        raise exc

    print("Committed!")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--atomic", action="store_true")
    parser.add_argument("-h", "--help", action="help")
    return parser.parse_args()


def main() -> int:
    try:
        args = parse_args()
        ensure_git_repo()

        if not has_committable_changes():
            if untracked_files():
                raise LzcError("Only untracked files detected. lzc only commits tracked or already staged changes.")
            raise LzcError("No changes detected in the Git repository.")

        if args.atomic:
            atomic_commit()
        else:
            single_commit()
        return 0
    except KeyboardInterrupt:
        print("")
        return 130
    except LzcError as exc:
        print(str(exc))
        return 1


if __name__ == "__main__":
    sys.exit(main())
