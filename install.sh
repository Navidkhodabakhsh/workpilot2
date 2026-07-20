#!/usr/bin/env bash
# Installs Docker (if missing) and starts WorkPilot (Tadvin Hesab) on Ubuntu.
# Run from inside the extracted project directory: ./install.sh
set -euo pipefail

if ! command -v docker &>/dev/null; then
  echo "Docker not found -- installing..."
  sudo apt-get update
  sudo apt-get install -y docker.io docker-compose-plugin
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
  echo
  echo "Docker was just installed. Log out and back in (or reboot) so your user"
  echo "picks up docker-group permissions, then re-run ./install.sh."
  exit 0
fi

if ! docker compose version &>/dev/null; then
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

docker compose up -d --build

cat <<'EOF'

Done. WorkPilot is starting up:
  Frontend:      http://localhost:5173
  Backend docs:  http://localhost:8000/docs

A demo organization is auto-seeded on a brand-new database (see
backend/seed/README.md for the full phone/password list -- every
account's password is Test@1234). If you ran this stack before on this
machine without seed data, the old database volume already exists and
won't get reseeded automatically; run this once to force a clean, seeded
database:
  docker compose down -v && docker compose up -d --build

Check status with:   docker compose ps
Follow logs with:    docker compose logs -f
Stop everything with: docker compose down
EOF
