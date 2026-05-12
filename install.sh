#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/wwnbb/based_agents"
REF="master"

TEMP_DIR=""
MIGRATION_READY=0
CREATED_COUNT=0
REPLACED_COUNT=0
MIGRATED_COUNT=0
SKIPPED_COUNT=0

log() {
  printf '%s\n' "$*"
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

cleanup() {
  if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}

trap cleanup EXIT

if command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
  TARGET_ROOT=$(git rev-parse --show-toplevel)
else
  TARGET_ROOT=$(pwd -P)
fi

download_source_root() {
  command -v curl >/dev/null 2>&1 || die "curl is required"
  command -v tar >/dev/null 2>&1 || die "tar is required"

  local archive_path entry found
  TEMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t based-agents)
  archive_path="$TEMP_DIR/source.tar.gz"

  curl -fsSL "$REPO_URL/archive/$REF.tar.gz" -o "$archive_path"
  tar -xzf "$archive_path" -C "$TEMP_DIR"

  found=""
  for entry in "$TEMP_DIR"/*; do
    if [ -d "$entry" ]; then
      found=$entry
      break
    fi
  done

  [ -n "$found" ] || die "downloaded framework archive is empty"
  (cd "$found" && pwd -P)
}

resolve_source_root() {
  local script_path script_dir
  script_path=${BASH_SOURCE[0]:-}

  if [ -n "$script_path" ] && [ -f "$script_path" ]; then
    script_dir=$(dirname "$script_path")
    (cd "$script_dir" && pwd -P)
    return
  fi

  download_source_root
}

SOURCE_ROOT=$(resolve_source_root)
MIGRATION_ROOT="$TARGET_ROOT/.migration/based-agents-$(date +%Y%m%d%H%M%S)"

target_rel() {
  case "$1" in
    "$TARGET_ROOT"/*) printf '%s' "${1#$TARGET_ROOT/}" ;;
    "$TARGET_ROOT") printf '.' ;;
    *) printf '%s' "$1" ;;
  esac
}

prepare_migration_root() {
  [ "$MIGRATION_READY" -eq 1 ] && return

  if [ -e "$TARGET_ROOT/.migration" ] && [ ! -d "$TARGET_ROOT/.migration" ]; then
    die "$TARGET_ROOT/.migration exists and is not a directory"
  fi

  mkdir -p "$MIGRATION_ROOT"
  MIGRATION_READY=1
}

migrate_existing_path() {
  local existing=$1
  local rel backup

  rel=$(target_rel "$existing")
  backup="$MIGRATION_ROOT/$rel"

  prepare_migration_root
  mkdir -p "$(dirname "$backup")"
  mv "$existing" "$backup"

  MIGRATED_COUNT=$((MIGRATED_COUNT + 1))
  log "migrate  $rel -> .migration/$(basename "$MIGRATION_ROOT")/$rel"
}

ensure_dir() {
  local dir=$1
  local parent

  if [ -d "$dir" ]; then
    return
  fi

  if [ -e "$dir" ] || [ -L "$dir" ]; then
    migrate_existing_path "$dir"
  fi

  parent=$(dirname "$dir")
  if [ "$parent" != "$dir" ] && [ ! -d "$parent" ]; then
    ensure_dir "$parent"
  fi

  mkdir -p "$dir"
}

copy_file() {
  local src=$1
  local dst=$2
  local rel parent

  rel=$(target_rel "$dst")

  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    log "skip     $rel"
    return
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    migrate_existing_path "$dst"
    REPLACED_COUNT=$((REPLACED_COUNT + 1))
    log "replace  $rel"
  else
    CREATED_COUNT=$((CREATED_COUNT + 1))
    log "create   $rel"
  fi

  parent=$(dirname "$dst")
  ensure_dir "$parent"
  cp -p "$src" "$dst"
}

copy_tree() {
  local src_dir=$1
  local dst_dir=$2
  local src rel found

  [ -d "$src_dir" ] || die "source directory not found: $src_dir"
  ensure_dir "$dst_dir"

  found=0
  while IFS= read -r -d '' src; do
    found=1
    rel=${src#$src_dir/}
    copy_file "$src" "$dst_dir/$rel"
  done < <(find "$src_dir" -type f ! -name '.DS_Store' -print0)

  [ "$found" -eq 1 ] || die "source directory contains no files: $src_dir"
}

log "Installing BASED Agent Framework"
log "Target: $TARGET_ROOT/.agents/agents"

[ -d "$SOURCE_ROOT/agents" ] || die "framework source must contain agents/"
copy_tree "$SOURCE_ROOT/agents" "$TARGET_ROOT/.agents/agents"
ensure_dir "$TARGET_ROOT/specs"
ensure_dir "$TARGET_ROOT/llm_context"

log "Install complete."
log "Created:  $CREATED_COUNT"
log "Replaced: $REPLACED_COUNT"
log "Migrated: $MIGRATED_COUNT"
log "Skipped:  $SKIPPED_COUNT"

if [ "$MIGRATED_COUNT" -gt 0 ]; then
  log "Migration backup: $MIGRATION_ROOT"
fi
