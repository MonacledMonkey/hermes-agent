#!/bin/sh
# Start or reuse the agent-owned virtual GUI session, then optionally run a command.
# Intended for non-interactive agent smokes: Xvfb + openbox + xdotool/import.
set -eu

DISPLAY_VALUE="${DISPLAY:-${HERMES_AGENT_GUI_DISPLAY:-:99}}"
SCREEN_GEOMETRY="${HERMES_AGENT_GUI_SCREEN:-1280x720x24}"
XVFB_LOG="${HERMES_AGENT_GUI_XVFB_LOG:-/tmp/hermes-agent-xvfb.log}"
OPENBOX_LOG="${HERMES_AGENT_GUI_OPENBOX_LOG:-/tmp/hermes-agent-openbox.log}"

export DISPLAY="$DISPLAY_VALUE"
export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-1}"
export ALSOFT_DRIVERS="${ALSOFT_DRIVERS:-null}"
export NO_AT_BRIDGE="${NO_AT_BRIDGE:-1}"

# Xvfb uses a lock file named /tmp/.X<N>-lock where DISPLAY is :<N>.
display_number=$(printf '%s' "$DISPLAY_VALUE" | sed 's/^://; s/\..*$//')
lock_file="/tmp/.X${display_number}-lock"

if [ ! -S "/tmp/.X11-unix/X${display_number}" ] && [ ! -f "$lock_file" ]; then
    Xvfb "$DISPLAY_VALUE" -screen 0 "$SCREEN_GEOMETRY" -nolisten tcp >"$XVFB_LOG" 2>&1 &
    # Give the socket a short bounded window to appear.
    i=0
    while [ "$i" -lt 50 ]; do
        [ -S "/tmp/.X11-unix/X${display_number}" ] && break
        i=$((i + 1))
        sleep 0.1
    done
fi

if command -v openbox >/dev/null 2>&1; then
    if ! DISPLAY="$DISPLAY_VALUE" wmctrl -m >/dev/null 2>&1; then
        DISPLAY="$DISPLAY_VALUE" openbox >"$OPENBOX_LOG" 2>&1 &
        sleep 0.5
    fi
fi

if [ "$#" -eq 0 ]; then
    printf 'AGENT_GUI_SESSION: READY\n'
    printf 'DISPLAY=%s\n' "$DISPLAY"
    printf 'LIBGL_ALWAYS_SOFTWARE=%s\n' "$LIBGL_ALWAYS_SOFTWARE"
    printf 'ALSOFT_DRIVERS=%s\n' "$ALSOFT_DRIVERS"
    exit 0
fi

if [ "${1:-}" = "--" ]; then
    shift
fi

exec "$@"
