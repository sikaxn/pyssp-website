#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_OUT_DIR="$ROOT_DIR/docs"
LOCAL_SOURCE_REPO="${PYSSP_LOCAL_REPO:-$ROOT_DIR/../pySSP}"
REMOTE_SOURCE_REPO="${PYSSP_REPO_URL:-https://github.com/sikaxn/pySSP.git}"
REMOTE_SOURCE_REF="${PYSSP_REPO_REF:-}"

cleanup() {
  if [[ -n "${TEMP_REPO_DIR:-}" && -d "${TEMP_REPO_DIR:-}" ]]; then
    rm -rf "$TEMP_REPO_DIR"
  fi
}

trap cleanup EXIT

if [[ -d "$LOCAL_SOURCE_REPO/docs/source" ]]; then
  SOURCE_REPO="$LOCAL_SOURCE_REPO"
  echo "Using local pySSP repo: $SOURCE_REPO"
else
  TEMP_REPO_DIR="$(mktemp -d)"
  echo "Cloning pySSP repo into $TEMP_REPO_DIR"
  git clone --depth 1 "$REMOTE_SOURCE_REPO" "$TEMP_REPO_DIR"
  if [[ -n "$REMOTE_SOURCE_REF" ]]; then
    git -C "$TEMP_REPO_DIR" fetch --depth 1 origin "$REMOTE_SOURCE_REF"
    git -C "$TEMP_REPO_DIR" checkout "$REMOTE_SOURCE_REF"
  fi
  SOURCE_REPO="$TEMP_REPO_DIR"
fi

python -m pip install --upgrade pip
python -m pip install \
  "sphinx>=9.1" \
  "myst-parser>=5.0" \
  "sphinx-rtd-theme>=3.1"

rm -rf "$DOCS_OUT_DIR"
mkdir -p "$DOCS_OUT_DIR"

python -m sphinx -b html \
  "$SOURCE_REPO/docs/source" \
  "$DOCS_OUT_DIR"

echo "Built docs into $DOCS_OUT_DIR"
