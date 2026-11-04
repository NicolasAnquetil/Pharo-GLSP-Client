#!/usr/bin/env bash
# Start the Workflow example server of Eclipse GLSP (Java), for GLSPEclipseWorkflowServerTest.
# Usage: interop/start-workflow-server.sh [port]   (default port: 5007, the port of the tests)
# Needs Java 17+. The jar is downloaded once from Maven Central and checked against its SHA-256.
set -euo pipefail
VERSION=2.8.0
PORT="${1:-5007}"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/pharo-glsp-client"
JAR="$CACHE/org.eclipse.glsp.example.workflow-$VERSION-glsp.jar"
URL="https://repo1.maven.org/maven2/org/eclipse/glsp/example/org.eclipse.glsp.example.workflow/$VERSION/$(basename "$JAR")"
mkdir -p "$CACHE"
if [ ! -f "$JAR" ]; then
  curl -sfL -o "$JAR.part" "$URL"
  echo "$(curl -sfL "$URL.sha256")  $JAR.part" | sha256sum -c --quiet
  mv "$JAR.part" "$JAR"
fi
exec java -jar "$JAR" --port "$PORT"
