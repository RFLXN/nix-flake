#!/usr/bin/env bash
set -euo pipefail

APPID="${APPID:-2357570}"
STYLE="${2:-overthespot}"
ACTION="${1:-apply}"
TARGETS=("overwatch.exe" "battle.net.exe")

export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/proton-reg-xdg-cache}"
mkdir -p "$XDG_CACHE_HOME"

usage() {
  cat <<'EOF'
Usage:
  ./proton-reg.sh [apply|query|reset] [overthespot|offthespot|root]

Examples:
  ./proton-reg.sh
  ./proton-reg.sh apply overthespot
  ./proton-reg.sh query
  ./proton-reg.sh reset

Environment:
  APPID=2357570   Override Steam app ID if needed.
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

proton_cmd() {
  protontricks -c "$1" "$APPID"
}

get_prefix() {
  proton_cmd 'printf %s "$WINEPREFIX"'
}

validate_style() {
  case "$1" in
    overthespot|offthespot|root) ;;
    *)
      printf 'Invalid InputStyle: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
}

apply_key() {
  local app="$1"
  local style="$2"
  proton_cmd "wine reg add \"HKCU\\\\Software\\\\Wine\\\\AppDefaults\\\\${app}\\\\X11 Driver\" /v UseXIM /t REG_SZ /d Y /f"
  proton_cmd "wine reg add \"HKCU\\\\Software\\\\Wine\\\\AppDefaults\\\\${app}\\\\X11 Driver\" /v InputStyle /t REG_SZ /d ${style} /f"
}

query_key() {
  local app="$1"
  proton_cmd "wine reg query \"HKCU\\\\Software\\\\Wine\\\\AppDefaults\\\\${app}\\\\X11 Driver\""
}

delete_key() {
  local app="$1"
  proton_cmd "wine reg delete \"HKCU\\\\Software\\\\Wine\\\\AppDefaults\\\\${app}\\\\X11 Driver\" /f"
}

require_cmd protontricks

case "$ACTION" in
  apply)
    validate_style "$STYLE"
    prefix="$(get_prefix)"
    backup="/tmp/overwatch-user.reg.$(date +%s).bak"
    cp "$prefix/user.reg" "$backup"
    printf 'Prefix: %s\n' "$prefix"
    printf 'Backup: %s\n' "$backup"
    for app in "${TARGETS[@]}"; do
      apply_key "$app" "$STYLE"
      query_key "$app"
    done
    ;;
  query)
    prefix="$(get_prefix)"
    printf 'Prefix: %s\n' "$prefix"
    for app in "${TARGETS[@]}"; do
      query_key "$app"
    done
    ;;
  reset)
    prefix="$(get_prefix)"
    printf 'Prefix: %s\n' "$prefix"
    for app in "${TARGETS[@]}"; do
      delete_key "$app" || true
    done
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    printf 'Unknown action: %s\n' "$ACTION" >&2
    usage >&2
    exit 1
    ;;
esac
