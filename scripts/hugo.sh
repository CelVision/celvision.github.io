#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cache_bin="${HUGO_CACHE_DIR:-$repo_root/.cache/hugo}/bin/hugo"

if [[ -n "${HUGO_BIN:-}" && -x "${HUGO_BIN}" ]]; then
    exec "${HUGO_BIN}" "$@"
fi

if command -v hugo >/dev/null 2>&1; then
    if hugo version >/dev/null 2>&1; then
        exec hugo "$@"
    fi
fi

if [[ -x "$cache_bin" ]]; then
    if "$cache_bin" version >/dev/null 2>&1; then
        exec "$cache_bin" "$@"
    fi
fi

if ! command -v go >/dev/null 2>&1; then
    echo "Hugo is not available, and Go is not installed to bootstrap it." >&2
    echo "Install Go or set HUGO_BIN to a working Hugo executable." >&2
    exit 1
fi

cache_dir="$(dirname "$cache_bin")"
mkdir -p "$cache_dir"

hugo_version="${HUGO_VERSION:-latest}"
if [[ "$hugo_version" != "latest" && "$hugo_version" != v* ]]; then
    hugo_version="v${hugo_version}"
fi

GOBIN="$cache_dir" go install -tags extended github.com/gohugoio/hugo@"${hugo_version}"

exec "$cache_bin" "$@"