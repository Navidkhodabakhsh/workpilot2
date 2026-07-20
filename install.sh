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

# Regenerated every run (cheap, no secrets in it) so the frontend/backend
# stay reachable from outside this machine -- e.g. a Windows host browsing
# into this VM -- where "localhost" would otherwise point at Windows
# itself instead of here. docker-compose.yml reads these via ${VAR:-...}.
vm_ip=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')
vm_ip=${vm_ip:-$(hostname -I 2>/dev/null | awk '{print $1}')}
if [ -n "${vm_ip:-}" ]; then
  cat > .env <<ENVEOF
VITE_API_BASE_URL=http://${vm_ip}:8000
CORS_ORIGINS=["http://localhost:5173","http://127.0.0.1:5173","http://${vm_ip}:5173"]
ENVEOF
fi

$COMPOSE up -d --build

# The initdb-based seed (backend/seed/demo_org_dump.sql) only loads on a
# brand-new Postgres volume -- it's silently skipped if this machine ran
# the stack before (even with an older compose file, before seeding
# existed). So *also* run the seed script directly against whatever
# database is actually live right now; it's idempotent (skips cleanly if
# the demo org is already there), so this is safe to do on every run.
echo "Waiting for the backend to be ready..."
backend_ready=false
for _ in $(seq 1 30); do
  if $COMPOSE exec -T backend python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health', timeout=2)" &>/dev/null; then
    backend_ready=true
    break
  fi
  sleep 2
done

if [ "$backend_ready" = true ]; then
  echo "Ensuring demo login data exists..."
  $COMPOSE exec -T -e PYTHONPATH=. backend python scripts/seed_demo_org.py \
    || echo "Seeding failed -- check '$COMPOSE logs backend' and see backend/seed/README.md."
else
  echo "Backend didn't come up in time -- skipping auto-seed. Once it's up, run:"
  echo "  $COMPOSE exec -e PYTHONPATH=. backend python scripts/seed_demo_org.py"
fi

cat <<EOF

Done. WorkPilot is starting up:
  From inside this machine:  http://localhost:5173
  From Windows (or another machine on the network): http://${vm_ip:-<this-VM-IP>}:5173
  Backend docs:  http://${vm_ip:-localhost}:8000/docs

Demo login (see backend/seed/README.md for the full list) -- password for
every account is Test@1234, e.g. org_admin: 09100000001

Check status with:    $COMPOSE ps
Follow logs with:     $COMPOSE logs -f
Stop everything with: $COMPOSE down
EOF
