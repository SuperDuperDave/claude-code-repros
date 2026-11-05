# claude-code-repros

Minimal reproductions of Claude Code behavior, with the exact version they were measured on. Each directory is one finding: a script that runs inside Claude Code and prints expected versus actual.

| Directory | Finding | Measured on |
|---|---|---|
| [`grep-v-quiet/`](grep-v-quiet/) | The Bash tool's `grep` shim (embedded ugrep) returns the wrong exit status for `-v` when output is quiet (`-q`, or stdout redirected to `/dev/null`) | Claude Code 2.1.317 (the running process; the `claude` on PATH had since been updated to 2.1.318), Linux (WSL2), bash |

Run a script by sourcing it from the Bash tool, for example `source grep-v-quiet/repro.sh`; the shim is a shell function, so a child `bash` process would not see it. Re-run on a newer version and compare with the output file in each directory.

This finding is already filed as [anthropics/claude-code#88802](https://github.com/anthropics/claude-code/issues/88802) (macOS/zsh reports). This directory adds a Linux/WSL2 bash reproduction on 2.1.317, where the shim takes the bash branch (`exec -a ugrep` subshell) rather than the zsh one. Other shim issues: #103911, #98421, #101399, #105893.
