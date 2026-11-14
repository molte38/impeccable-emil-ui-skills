#!/bin/sh
# Installs Emil Kowalski's design-engineering skills and Impeccable into Claude Code.
#
#   ./install.sh --local            # into ./.claude/skills       (this project only, the default)
#   ./install.sh --global           # into ~/.claude/skills       (every project)
#   ./install.sh --dir ~/my-app     # into ~/my-app/.claude/skills
#
# Or without cloning:
#   curl -fsSL https://raw.githubusercontent.com/molte38/impeccable-emil-ui-skills/main/install.sh | sh -s -- --global
#
# It only copies skill folders. It never installs hooks, never edits settings.json, and never overwrites
# a skill you already have unless you pass --force. Run with --dry-run to see what it would do.
set -eu

REPO="${IMPECCABLE_EMIL_REPO:-molte38/impeccable-emil-ui-skills}"
REF="${IMPECCABLE_EMIL_REF:-main}"

scope=local
target_dir=""
force=0
dry=0
only=all

usage() {
  cat <<'EOF'
Usage: install.sh [--local | --global | --dir PROJECT] [--only emil|impeccable] [--force] [--dry-run]

  --local        install into ./.claude/skills (default)
  --global       install into ~/.claude/skills
  --dir PROJECT  install into PROJECT/.claude/skills
  --only SET     "emil" (the 19 Emil Kowalski skills) or "impeccable" (default: both)
  --force        replace skills that are already installed (otherwise they are skipped)
  --dry-run      print what would happen, change nothing
  -h, --help     this text
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --local) scope=local ;;
    --global) scope=global ;;
    --dir) shift; [ $# -gt 0 ] || { echo "install.sh: --dir needs a path" >&2; exit 2; }; scope=dir; target_dir="$1" ;;
    --only) shift; [ $# -gt 0 ] || { echo "install.sh: --only needs emil or impeccable" >&2; exit 2; }; only="$1" ;;
    --force) force=1 ;;
    --dry-run) dry=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "install.sh: unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done
case "$only" in all|emil|impeccable) ;; *) echo "install.sh: --only must be emil or impeccable" >&2; exit 2 ;; esac

case "$scope" in
  global) dest="${HOME:?HOME is not set}/.claude/skills" ;;
  dir) [ -d "$target_dir" ] || { echo "install.sh: not a directory: $target_dir" >&2; exit 2; }
       dest="$(cd "$target_dir" && pwd)/.claude/skills" ;;
  *) dest="$(pwd)/.claude/skills" ;;
esac

# Where do the skills come from? Next to this script when it sits in a clone, else download this repo.
cleanup() { [ -z "${tmp:-}" ] || rm -rf "$tmp"; }
trap cleanup EXIT INT TERM
src=""
case "$0" in
  */*) here="$(cd "${0%/*}" 2>/dev/null && pwd || true)" ;;
  *) here="$(pwd)" ;;
esac
if [ -n "$here" ] && [ -d "$here/.claude/skills/impeccable" ]; then
  src="$here/.claude/skills"
else
  tmp="$(mktemp -d 2>/dev/null || mktemp -d -t impeccable-emil)"
  url="https://codeload.github.com/$REPO/tar.gz/refs/heads/$REF"
  echo "Downloading $REPO@$REF ..."
  if command -v curl >/dev/null 2>&1; then curl -fsSL "$url" -o "$tmp/repo.tgz"
  elif command -v wget >/dev/null 2>&1; then wget -q "$url" -O "$tmp/repo.tgz"
  else echo "install.sh: need curl or wget to download the skills (or run this script from a clone)" >&2; exit 1; fi
  mkdir "$tmp/x" && tar -xzf "$tmp/repo.tgz" -C "$tmp/x"
  src="$(find "$tmp/x" -maxdepth 3 -type d -path '*/.claude/skills' | head -n 1)"
  [ -n "$src" ] && [ -d "$src/impeccable" ] || { echo "install.sh: the download did not contain .claude/skills" >&2; exit 1; }
fi

echo "Source: $src"
echo "Target: $dest"
[ "$dry" -eq 1 ] && echo "(dry run: nothing will be changed)"
[ "$dry" -eq 1 ] || mkdir -p "$dest"

installed=0
skipped=0
for skill_dir in "$src"/*/; do
  name="$(basename "$skill_dir")"
  [ -f "$skill_dir/SKILL.md" ] || continue
  case "$only" in
    emil) [ "$name" != impeccable ] || continue ;;
    impeccable) [ "$name" = impeccable ] || continue ;;
  esac
  case "$name" in ''|.|..|*/*) continue ;; esac     # never build a path from an odd name
  if [ -e "$dest/$name" ]; then
    if [ "$force" -eq 1 ]; then
      echo "  replace  $name"
      [ "$dry" -eq 1 ] || rm -rf "${dest:?}/$name"
    else
      echo "  skip     $name (already installed; use --force to replace)"
      skipped=$((skipped + 1))
      continue
    fi
  else
    echo "  install  $name"
  fi
  [ "$dry" -eq 1 ] || cp -Rp "$skill_dir" "$dest/$name"
  installed=$((installed + 1))
done

echo
echo "Done: $installed installed or replaced, $skipped skipped."
[ "$dry" -eq 1 ] && exit 0
cat <<EOF

Next:
  1. Restart Claude Code (or start a new session) so it picks up the skills.
  2. Try:  /impeccable critique   or   /emil-design-eng   (see the README for prompts).
  Note: Impeccable's engine binary downloads once from the project's own releases on first use and is
  verified against the SHA-256 digests shipped in the skill. Its optional design hook is NOT installed by
  this script; to add it, run:  npx impeccable install
EOF
