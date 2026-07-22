#!/usr/bin/env bash
# "Sync from wherever this script currently lives, then (re)build & start."
#
# Not meant to be installed globally by itself anymore -- see
# run-bootstrap.sh, which IS installed once at /usr/local/bin/run and
# finds/execs *this* file fresh every time (from a zip or an already
# extracted folder in the VMware shared folder). That split means any
# future fix or feature added here takes effect on your very next `run`,
# with nothing to reinstall.
set -euo pipefail

# Resolve our own location: run-bootstrap.sh finds and execs this exact
# file wherever it landed (an extracted zip's temp dir, or directly in
# the shared folder), so "where this script lives" already IS the
# project source -- no separate search for docker-compose.yml needed.
SRC="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
DEST="$HOME/workpilot2"

command -v rsync &>/dev/null || { sudo apt-get update -qq && sudo apt-get install -y rsync; }

mkdir -p "$DEST"
# __pycache__/.pyc are written by the backend container (running as root)
# into this bind-mounted dir -- excluding them means rsync never tries to
# touch (and fails to delete, as a non-root user) those root-owned files.
#
# ".env" is excluded for a different, more important reason: it's
# git-ignored, so it never exists in $SRC (the freshly extracted/synced
# project) -- without this exclude, --delete would treat the *real*
# backend/.env already sitting in $DEST (your SECRET_KEY, any
# KAVENEGAR_API_KEY you've added, etc.) as "extraneous" and erase it on
# every single run, silently, right before install.sh even starts.
rsync -a --delete \
  --exclude ".venv" --exclude "node_modules" \
  --exclude "__pycache__" --exclude "*.pyc" \
  --exclude ".pytest_cache" --exclude "dist" \
  --exclude ".env" \
  "$SRC"/ "$DEST"/
cd "$DEST"
chmod +x install.sh
exec ./install.sh
