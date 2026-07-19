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

Check status with:   docker compose ps
Follow logs with:    docker compose logs -f
Stop everything with: docker compose down
EOF
