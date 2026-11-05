# `grep -v` with quiet output returns the wrong exit status in the Bash tool

In Claude Code's Bash tool, `grep` is a shell function that execs the bundled ugrep (`type grep` shows it). For `-v` combined with quiet output, its exit status disagrees with POSIX/GNU grep:

```
type grep: grep is a function
grep -vq a two.txt                 expected=0 got=1  MISMATCH
grep -vq b two.txt                 expected=0 got=1  MISMATCH
grep -vq x empty.txt               expected=1 got=0  MISMATCH
grep -v a two.txt >/dev/null       expected=0 got=1  MISMATCH
grep -v a two.txt | cat            expected=0 got=0  ok
grep -q a two.txt                  expected=0 got=0  ok
```

(`two.txt` holds the lines `a` and `b`; `empty.txt` is empty. Claude Code 2.1.317 (the running process; the `claude` on PATH had since been updated to 2.1.318). Output of the script: [`output-claude-code-2.1.317.txt`](output-claude-code-2.1.317.txt).)

Observed pattern: with `-v` and quiet output, the status is 1 whenever the pattern matches some line and 0 when it matches none, instead of "0 if any line is selected". With a pipe or a file as stdout, or without `-v`, the status is correct. `/usr/bin/grep` returns the expected values in every case above. This is an observation, not a diagnosis of ugrep.

Why it matters: `if grep -vq PATTERN file; then ...` and `grep -v PATTERN file >/dev/null && ...` silently take the wrong branch; agents and scripts that gate on grep's status (for example "any line other than the allowed ones?") get inverted answers.

Workaround: `command grep ...` (or `/usr/bin/grep`) bypasses the shim.

Run: `source repro.sh` from the Bash tool.

Already reported as [anthropics/claude-code#88802](https://github.com/anthropics/claude-code/issues/88802) (macOS/zsh, 2.1.239 to 2.1.317). This repro adds Linux/WSL2 bash coverage; the pattern here matches that issue's rule (exit 0 only if some input has a line that fails to match, evaluated per file).
