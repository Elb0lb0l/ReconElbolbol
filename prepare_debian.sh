#!/usr/bin/env bash
set -euo pipefail

echo "[*] Updating apt and installing prerequisites..."
sudo apt update
sudo apt install -y build-essential git curl wget unzip ca-certificates \
    python3 python3-pip python3-venv golang-go figlet snapd

echo "[*] Ensuring snapd is running (needed only if we use snap)"
sudo systemctl enable --now snapd.socket || true

# Ensure go bin and pip user bin are in PATH (persist)
GOBIN_DIR="$(go env GOPATH 2>/dev/null || echo "$HOME/go")/bin"
PIPUSER_BIN="$HOME/.local/bin"

if ! grep -q "$GOBIN_DIR" ~/.profile 2>/dev/null; then
  echo "export PATH=\"\$PATH:$GOBIN_DIR:$PIPUSER_BIN\"" >> ~/.profile
  echo "[*] Added $GOBIN_DIR and $PIPUSER_BIN to PATH in ~/.profile"
fi
export PATH="$PATH:$GOBIN_DIR:$PIPUSER_BIN"

echo "[*] Installing go tools (using go install) — binaries go to $GOBIN_DIR"
# go install tools (matches your arch script)
GO_OPTS=""

# waybackurls
echo "[*] Installing waybackurls (tomnomnom)"
go install github.com/tomnomnom/waybackurls@latest

# gospider
echo "[*] Installing gospider (jaeles-project)"
go install github.com/jaeles-project/gospider@latest

sudo apt install -y libnotify-bin

# katana (projectdiscovery)
echo "[*] Installing katana (projectdiscovery)"
# Katana may need a newer Go; if installation fails, update Go.
CGO_ENABLED=1 go install github.com/projectdiscovery/katana/cmd/katana@latest

# cariddi (either snap or go)
echo "[*] Installing cariddi (via go). If you prefer snap, see notes below."
go install github.com/edoardottt/cariddi/cmd/cariddi@latest

# paramx
echo "[*] Installing paramx"
go install github.com/m3n0sd0n4ld/paramx@latest

# kxss
echo "[*] Installing kxss"
go install github.com/Emoe/kxss@latest

# jsleak
echo "[*] Installing jsleak"
go install github.com/channyein1337/jsleak@latest

# dalfox
echo "[*] Installing dalfox"
go install github.com/hahwul/dalfox/v2@latest

echo "[*] Copying go binaries to /usr/local/bin (optional: requires sudo)"
# Optional: copy to /usr/local/bin so they are globally available
if [ -d "$GOBIN_DIR" ]; then
  sudo cp -u "$GOBIN_DIR"/* /usr/local/bin/ || true
fi

echo "[*] Installing Python tools with pip (user install)"
python3 -m pip install --upgrade pip setuptools wheel
python3 -m pip install --user waymore arjun bbot

echo "[*] Installing ParamSpider (git + pip)"
# ParamSpider: repo -> pip install
TMPDIR="$(mktemp -d)"
git clone https://github.com/devanshbatham/ParamSpider.git "$TMPDIR/ParamSpider"
python3 -m pip install --user "$TMPDIR/ParamSpider"
rm -rf "$TMPDIR"

echo "[*] Installing figlet is done via apt (already installed)."

echo "[*] Final PATH check — you might want to logout/login to pick up ~/.profile changes."
echo "PATH now includes: $PATH"
echo "Installed go bin location: $GOBIN_DIR"
echo
echo "Done. Examples:"
echo " - waybackurls (run: echo example.com | waybackurls )"
