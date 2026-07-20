#!/usr/bin/env bash
# Installs Docker (if missing) and starts WorkPilot (Tadvin Hesab) on Ubuntu.
# Run from inside the extracted project directory: ./install.sh
set -euo pipefail

if ! command -v docker &>/dev/null; then
  echo "Docker not found -- installing..."
  sudo apt-get update
  sudo apt-get install -y docker.io docker-compose-plugin
  sudo systemctl enable --now docker
fi

# `docker info` (not just `command -v docker`) also catches "installed but
# this user isn't in the docker group yet" (permission denied on the
# socket) -- common right after a fresh install, since group membership
# only takes effect in a new login session. Rather than force a
# logout/reboot mid-script, fall back to `sudo docker`/`sudo docker
# compose` for this run, while still fixing group membership for next time.
COMPOSE="docker compose"
if ! docker info &>/dev/null 2>&1; then
  if ! groups "$USER" | grep -qw docker; then
    sudo usermod -aG docker "$USER"
    echo "Added $USER to the docker group (active starting next login)."
  fi
  echo "Docker group membership isn't active in this shell yet -- using sudo for this run."
  COMPOSE="sudo docker compose"
fi

if ! $COMPOSE version &>/dev/null; then
  echo "docker compose plugin not found -- installing..."
  sudo apt-get update
  sudo apt-get install -y docker-compose-plugin
fi

if [ ! -f backend/.env ]; then
  cp backend/.env.example backend/.env
  if command -v openssl &>/dev/null; then
    secret=$(openssl rand -hex 32)
    sed -i "s/^SECRET_KEY=.*/SECRET_KEY=${secret}/" backend/.env
  fi
  echo "Created backend/.env (with a random SECRET_KEY)."
fi

$COMPOSE up -d --build

cat <<EOF

Done. WorkPilot is starting up:
  Frontend:      http://localhost:5173
  Backend docs:  http://localhost:8000/docs

A demo organization is auto-seeded on a brand-new database (see
backend/seed/README.md for the full phone/password list -- every
account's password is Test@1234). If you ran this stack before on this
machine without seed data, the old database volume already exists and
won't get reseeded automatically; run this once to force a clean, seeded
database:
  $COMPOSE down -v && $COMPOSE up -d --build

Check status with:    $COMPOSE ps
Follow logs with:     $COMPOSE logs -f
Stop everything with: $COMPOSE down
EOF
