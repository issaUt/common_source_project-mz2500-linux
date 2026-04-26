#!/usr/bin/env bash
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
EMU_DIR="${EMU_DIR:-$SCRIPT_DIR/build-mz2500}"
EMU_BIN="$EMU_DIR/emumz2500"
DEFAULT_APP_DIR="$SCRIPT_DIR/runtime/mz2500"
APP_DIR="${MZ2500_APPDIR:-$DEFAULT_APP_DIR}"

if [ ! -x "$EMU_BIN" ]; then
  echo "emulator binary not found: $EMU_BIN" >&2
  exit 1
fi

CALLER_PWD="$(pwd)"

normalize_path() {
  local p="$1"
  p="${p//$'\r'/}"
  p="${p//$'\n'/}"
  p="${p#${p%%[![:space:]]*}}"
  p="${p%${p##*[![:space:]]}}"
  if [ -z "$p" ]; then
    printf '%s' ""
    return
  fi
  if [ "${p#/}" = "$p" ]; then
    p="$CALLER_PWD/$p"
  fi
  if command -v realpath >/dev/null 2>&1; then
    realpath -m -- "$p"
  else
    printf '%s' "$p"
  fi
}

FD0_IMAGE="${MZ2500_FD0:-}"
FD1_IMAGE="${MZ2500_FD1:-}"
FD2_IMAGE="${MZ2500_FD2:-}"
FD3_IMAGE="${MZ2500_FD3:-}"
STATE_FILE="${MZ2500_STATE:-}"
STATE_SLOT="${MZ2500_STATE_SLOT:-}"
WINDOW_POS="${MZ2500_WINDOW_POS:-}"

POSITIONAL_ARGS=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --fd0)
      [ "$#" -ge 2 ] || { echo "missing value for --fd0" >&2; exit 1; }
      FD0_IMAGE="$2"
      shift 2
      ;;
    --fd1)
      [ "$#" -ge 2 ] || { echo "missing value for --fd1" >&2; exit 1; }
      FD1_IMAGE="$2"
      shift 2
      ;;
    --fd2)
      [ "$#" -ge 2 ] || { echo "missing value for --fd2" >&2; exit 1; }
      FD2_IMAGE="$2"
      shift 2
      ;;
    --fd3)
      [ "$#" -ge 2 ] || { echo "missing value for --fd3" >&2; exit 1; }
      FD3_IMAGE="$2"
      shift 2
      ;;
    --state)
      [ "$#" -ge 2 ] || { echo "missing value for --state" >&2; exit 1; }
      STATE_FILE="$2"
      shift 2
      ;;
    --state-slot)
      [ "$#" -ge 2 ] || { echo "missing value for --state-slot" >&2; exit 1; }
      STATE_SLOT="$2"
      shift 2
      ;;
    --window-pos)
      POSITIONAL_ARGS+=("$1")
      [ "$#" -ge 2 ] || { echo "missing value for --window-pos" >&2; exit 1; }
      POSITIONAL_ARGS+=("$2")
      shift 2
      ;;
    --appdir)
      [ "$#" -ge 2 ] || { echo "missing value for --appdir" >&2; exit 1; }
      APP_DIR="$2"
      shift 2
      ;;
    --)
      shift
      while [ "$#" -gt 0 ]; do
        POSITIONAL_ARGS+=("$1")
        shift
      done
      ;;
    --*)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

APP_DIR="$(normalize_path "$APP_DIR")"
mkdir -p "$APP_DIR"
STATE_FILE="$(normalize_path "$STATE_FILE")"

if [ -n "$STATE_FILE" ]; then
  if [ "${#POSITIONAL_ARGS[@]}" -gt 0 ] && [ -z "$FD1_IMAGE" ]; then
    FD1_IMAGE="${POSITIONAL_ARGS[0]}"
    unset 'POSITIONAL_ARGS[0]'
    POSITIONAL_ARGS=("${POSITIONAL_ARGS[@]}")
  fi
  if [ "${#POSITIONAL_ARGS[@]}" -gt 0 ] && [ -z "$FD2_IMAGE" ]; then
    FD2_IMAGE="${POSITIONAL_ARGS[0]}"
    unset 'POSITIONAL_ARGS[0]'
    POSITIONAL_ARGS=("${POSITIONAL_ARGS[@]}")
  fi
  if [ "${#POSITIONAL_ARGS[@]}" -gt 0 ] && [ -z "$FD3_IMAGE" ]; then
    FD3_IMAGE="${POSITIONAL_ARGS[0]}"
    unset 'POSITIONAL_ARGS[0]'
    POSITIONAL_ARGS=("${POSITIONAL_ARGS[@]}")
  fi
else
  if [ "${#POSITIONAL_ARGS[@]}" -gt 0 ] && [ -z "$FD0_IMAGE" ]; then
    FD0_IMAGE="${POSITIONAL_ARGS[0]}"
    unset 'POSITIONAL_ARGS[0]'
    POSITIONAL_ARGS=("${POSITIONAL_ARGS[@]}")
  fi
  if [ "${#POSITIONAL_ARGS[@]}" -gt 0 ] && [ -z "$FD1_IMAGE" ]; then
    FD1_IMAGE="${POSITIONAL_ARGS[0]}"
    unset 'POSITIONAL_ARGS[0]'
    POSITIONAL_ARGS=("${POSITIONAL_ARGS[@]}")
  fi
  if [ "${#POSITIONAL_ARGS[@]}" -gt 0 ] && [ -z "$FD2_IMAGE" ]; then
    FD2_IMAGE="${POSITIONAL_ARGS[0]}"
    unset 'POSITIONAL_ARGS[0]'
    POSITIONAL_ARGS=("${POSITIONAL_ARGS[@]}")
  fi
  if [ "${#POSITIONAL_ARGS[@]}" -gt 0 ] && [ -z "$FD3_IMAGE" ]; then
    FD3_IMAGE="${POSITIONAL_ARGS[0]}"
    unset 'POSITIONAL_ARGS[0]'
    POSITIONAL_ARGS=("${POSITIONAL_ARGS[@]}")
  fi
fi

FD0_IMAGE="$(normalize_path "$FD0_IMAGE")"
FD1_IMAGE="$(normalize_path "$FD1_IMAGE")"
FD2_IMAGE="$(normalize_path "$FD2_IMAGE")"
FD3_IMAGE="$(normalize_path "$FD3_IMAGE")"

export QT_OPENGL="${QT_OPENGL:-desktop}"
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-xcb}"
export QT_XCB_GL_INTEGRATION="${QT_XCB_GL_INTEGRATION:-xcb_glx}"

cd "$EMU_DIR"

args=("--gl2")
if [ -n "$APP_DIR" ]; then
  args+=("--appdir" "$APP_DIR")
fi
if [ -n "$STATE_FILE" ]; then
  args+=("--state" "$STATE_FILE")
elif [ -n "$STATE_SLOT" ]; then
  args+=("--state-slot" "$STATE_SLOT")
fi
if [ -n "$FD0_IMAGE" ]; then
  args+=("--fd0" "$FD0_IMAGE")
fi
if [ -n "$FD1_IMAGE" ]; then
  args+=("--fd1" "$FD1_IMAGE")
fi
if [ -n "$FD2_IMAGE" ]; then
  args+=("--fd2" "$FD2_IMAGE")
fi
if [ -n "$FD3_IMAGE" ]; then
  args+=("--fd3" "$FD3_IMAGE")
fi
if [ -n "$WINDOW_POS" ]; then
  args+=("--window-pos" "$WINDOW_POS")
fi
args+=("${POSITIONAL_ARGS[@]}")

if [ -n "$WINDOW_POS" ] && command -v wmctrl >/dev/null 2>&1; then
  IFS=',' read -r window_x window_y <<EOF
$WINDOW_POS
EOF
  "$EMU_BIN" "${args[@]}" &
  emu_pid=$!
  for _ in $(seq 1 40); do
    if ! kill -0 "$emu_pid" 2>/dev/null; then
      wait "$emu_pid"
      exit $?
    fi
    if wmctrl -l | grep -F "emumz2500" >/dev/null 2>&1; then
      wmctrl -r "emumz2500" -e "0,${window_x},${window_y},-1,-1" >/dev/null 2>&1 || true
      break
    fi
    sleep 0.25
  done
  wait "$emu_pid"
  exit $?
fi

exec "$EMU_BIN" "${args[@]}"
