#!/usr/bin/env bash
# Battle-ready CTF setup for Ubuntu/WSL. Run as your normal user: bash setup-wsl.sh
# It sudo's only for apt (one password prompt). Idempotent: safe to re-run.
set -uo pipefail

echo "[*] apt packages"
sudo apt update
sudo apt install -y \
  build-essential git curl wget jq ripgrep netcat-openbsd \
  binwalk foremost libimage-exiftool-perl pngcheck steghide zbar-tools \
  sleuthkit p7zip-full fcrackzip poppler-utils qpdf \
  john hashcat hashid sqlmap gobuster ffuf nmap whois dnsutils \
  tshark pcapfix aircrack-ng tcpdump \
  gdb ltrace strace upx-ucl \
  imagemagick ffmpeg python3-pip python3-venv pipx

echo "[*] radare2 (not in 22.04 apt; install from source)"
if ! command -v radare2 >/dev/null 2>&1; then
  git clone --depth 1 https://github.com/radareorg/radare2 /tmp/radare2 2>/dev/null \
    && /tmp/radare2/sys/install.sh
fi

echo "[*] pipx tools (user)"
pipx ensurepath >/dev/null 2>&1
for p in pwntools volatility3 ROPgadget; do
  pipx install "$p" 2>/dev/null || pipx upgrade "$p" 2>/dev/null || true
done

echo "[*] gem tools (user)"
gem install --user-install zsteg one_gadget 2>/dev/null || true

echo "[*] stegseek (.deb, not in apt)"
if ! command -v stegseek >/dev/null 2>&1; then
  wget -q https://github.com/RickdeJager/stegseek/releases/download/v0.6/stegseek_0.6-1.deb -O /tmp/stegseek.deb \
    && sudo apt install -y /tmp/stegseek.deb
fi

echo "[*] wordlists -> ~/wordlists"
mkdir -p ~/wordlists
[ -f ~/wordlists/rockyou.txt ] || { \
  wget -q https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -O ~/wordlists/rockyou.txt; }
[ -d ~/wordlists/SecLists ] || git clone --depth 1 https://github.com/danielmiessler/SecLists ~/wordlists/SecLists

echo "[*] aliases"
AL="$(cd "$(dirname "$0")" && pwd)/aliases.sh"
grep -q "aliases.sh" ~/.zshrc 2>/dev/null || echo "export FLAG=H4G; source $AL" >> ~/.zshrc

echo
echo "[*] done. Open a new shell (or: source ~/.zshrc). Verify with:"
echo "    for t in binwalk john sqlmap radare2 upx fcrackzip 7z fls stegseek zbarimg pwntools ROPgadget; do command -v \$t || echo MISSING \$t; done"
echo "[*] CyberChef + Burp + Ghidra: install on Windows side (GUI), not WSL."
