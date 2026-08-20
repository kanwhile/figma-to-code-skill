#!/usr/bin/env bash
# Flags values that bypassed the project's token layer:
#   * arbitrary Tailwind utilities carrying a hex or a px   — bg-[#fafafa], rounded-[12px], text-[14px]
#   * raw hex literals inside inline styles                 — style={{ color: '#0f172a' }}, style="color:#0f172a"
#
# Usage:
#   check-arbitrary-values.sh                 # files changed vs HEAD, plus untracked (falls back to a full scan)
#   check-arbitrary-values.sh src/features    # only these paths
#
# Not flagged: %, rem, calc(), vh/vw/dvh arbitrary values — those usually have no token to map to.
# Skipped: stylesheets, config, build output, and dot-directories, where defining a value is the point
#          or the file is not source.
# Allowlist: put one regex per line in .figma-to-code-allow at the repo root for idioms this project has accepted
#            (e.g. max-w-\[480px\] for a fixed mobile shell). Comments (#) and blank lines are ignored.
set -uo pipefail

root=$(git rev-parse --show-toplevel 2>/dev/null) && cd "$root" || root=$(pwd)

list_files() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    if [ "$#" -gt 0 ]; then
      git ls-files -co --exclude-standard -- "$@"
    else
      { git diff --name-only HEAD; git ls-files -o --exclude-standard; } | sort -u
    fi
  else
    find "${@:-.}" -type f 2>/dev/null
  fi
}

files=$(list_files "$@" \
  | grep -E '\.(tsx|jsx|ts|js|mjs|vue|svelte|astro|html)$' \
  | grep -vE '(^|/)(node_modules|dist|build|out|coverage)/' \
  | grep -vE '(^|/)\.[^/]+/' \
  | grep -vE '(^|/)(tailwind\.config|.*\.tokens|tokens)\.[a-z]+$' )

if [ -z "$files" ]; then
  echo "check-arbitrary-values: no candidate files — nothing to check."
  exit 0
fi

count=$(printf '%s\n' "$files" | wc -l | tr -d ' ')

# tailwind arbitrary with hex/px  |  hex inside an inline style
pattern='\[#[0-9a-fA-F]{3,8}\]|\[[0-9]+(\.[0-9]+)?px\]|style\s*=\s*[{"'"'"'][^}"'"'"']*#[0-9a-fA-F]{3,8}'

allow_file=".figma-to-code-allow"
strip_allowed() {
  if [ -s "$allow_file" ]; then
    perl -e '
      open(my $a, "<", $ARGV[0]) or die;
      my @pats = grep { length && !/^\s*#/ } map { chomp; $_ } <$a>;
      while (my $line = <STDIN>) {
        my $probe = $line;
        $probe =~ s/$_//g for @pats;
        print $line if $probe =~ /\[#[0-9a-fA-F]{3,8}\]|\[[0-9]+(?:\.[0-9]+)?px\]|style\s*=\s*[{"\x27][^}"\x27]*#[0-9a-fA-F]{3,8}/;
      }' "$allow_file"
  else
    cat
  fi
}

hits=$(printf '%s\n' "$files" | tr '\n' '\0' | xargs -0 grep -nEH "$pattern" 2>/dev/null | strip_allowed)

if [ -z "$hits" ]; then
  echo "check-arbitrary-values: clean ($count files)."
  exit 0
fi

echo "check-arbitrary-values: values that bypassed the token layer — remap these (references/token-discipline.md):"
echo
printf '%s\n' "$hits"
echo
echo "Genuinely no token and no stock scale match? Stop and ask before keeping it."
echo "An idiom this project has accepted? Add its regex to $allow_file."
exit 1
