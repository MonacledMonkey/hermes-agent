#!/bin/sh
# Container-visible Defold Editor launcher.
# Mount the host Defold install at /opt/defold:ro, then call `defold [project-dir]`.
set -eu

DEFOLD_HOME="${DEFOLD_HOME:-/opt/defold}"

if [ -x "$DEFOLD_HOME/Defold" ]; then
    cd "$DEFOLD_HOME"
    exec "$DEFOLD_HOME/Defold" "$@"
fi

if [ -x "$DEFOLD_HOME/defold" ]; then
    cd "$DEFOLD_HOME"
    exec "$DEFOLD_HOME/defold" "$@"
fi

printf 'defold wrapper: no executable found at %s/Defold or %s/defold\n' "$DEFOLD_HOME" "$DEFOLD_HOME" >&2
printf 'Mount the host Defold install into the container, e.g. /opt/defold:/opt/defold:ro\n' >&2
exit 127
