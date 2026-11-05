#!/usr/bin/env bash
# Run with `source repro.sh` inside Claude Code's Bash tool (grep is a shell function there, so a
# child `bash repro.sh` would not see it). Compares the function's exit status with POSIX expectations
# for `grep -v` with quiet output (-q, or stdout redirected to /dev/null). Returns 1 on any mismatch.
d=$(mktemp -d); pushd "$d" >/dev/null || return 2
printf 'a\nb\n' > two.txt; : > empty.txt
bad=0
check() {  # expected-status, command-string (evaluated in this shell, stdin from /dev/null)
  local want=$1 cmd=$2 got
  eval "$cmd" </dev/null >/dev/null 2>&1; got=$?
  if [ "$got" = "$want" ]; then r=ok; else r=MISMATCH; bad=1; fi
  printf '%-34s expected=%s got=%s  %s\n' "$cmd" "$want" "$got" "$r"
}
echo "type grep: $(type grep 2>&1 | head -1)"
check 0 "grep -vq a two.txt"          # line 'b' does not match 'a' -> selected
check 0 "grep -vq b two.txt"          # line 'a' does not match 'b' -> selected
check 1 "grep -vq x empty.txt"        # no lines -> nothing selected
check 0 "grep -v a two.txt >/dev/null"    # same as above, quiet via /dev/null
check 0 "grep -v a two.txt | cat"     # stdout is a pipe: correct
check 0 "grep -q a two.txt"           # without -v: correct
popd >/dev/null; rm -rf "$d"
return $bad 2>/dev/null || exit $bad
