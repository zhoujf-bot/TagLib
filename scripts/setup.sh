#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="${ROOT_DIR}/scripts"
VENV_DIR="${SCRIPTS_DIR}/.venv"
ENV_FILE="${SCRIPTS_DIR}/.env"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found. Please install Python 3 on this server." >&2
  exit 1
fi

if ! python3 -c "import venv" >/dev/null 2>&1; then
  echo "Python venv module not available. Install python3-venv (or equivalent) first." >&2
  exit 1
fi

if [ ! -d "${VENV_DIR}" ]; then
  python3 -m venv "${VENV_DIR}"
fi

source "${VENV_DIR}/bin/activate"

python -m pip install --upgrade pip
python -m pip install -r "${SCRIPTS_DIR}/requirements.txt"

if [ ! -f "${ENV_FILE}" ]; then
  cat > "${ENV_FILE}" <<'EOF'
# Freesound credentials
FREESOUND_API_KEY=
FREESOUND_CLIENT_ID=
FREESOUND_REDIRECT_URL=
EOF
  echo "Created ${ENV_FILE}. Fill in your Freesound values before running fixtures."
fi

echo "Setup complete."
