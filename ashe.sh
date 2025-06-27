#!/bin/bash

# user inputs
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <project_name> <target_ip>"
  exit 1
fi

# vars
PROJECT_NAME="$1"
TARGET="$2"
BASE_DIR="./$PROJECT_NAME"
WORDLIST="/home/drew/tools/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt"

TOOLS=("nmap" "gobuster" "whatweb" "nikto" "ffuf" "sslscan")

# create folders
echo "[+] Creating base folder: $BASE_DIR"
mkdir -p "$BASE_DIR"

for TOOL in "${TOOLS[@]}"; do
  mkdir -p "$BASE_DIR/$TOOL"
done

# running tools
echo "[+] Running nmap..."
nmap -Pn -sV -oN "$BASE_DIR/nmap/nmap.txt" "$TARGET" &

echo "[+] Running gobuster..."
gobuster dir -u "http://$TARGET" -w "$WORDLIST" --no-error -o "$BASE_DIR/gobuster/gobuster.txt" &

echo "[+] Running whatweb..."
whatweb "$TARGET" > "$BASE_DIR/whatweb/whatweb.txt" &

echo "[+] Running nikto..."
nikto -h "$TARGET" -output "$BASE_DIR/nikto/nikto.txt" &

echo "[+] Running ffuf..."
ffuf -u "http://$TARGET/FUZZ" -w "$WORDLIST" -of html -o "$BASE_DIR/ffuf/ffuf.html" -fc 404 &

echo "[+] Running sslscan..."
sslscan --no-colour "$TARGET" > "$BASE_DIR/sslscan/sslscan.txt" &

# wait for everything to finish running
wait
echo "[+] All recon tools finished. Output saved in: $BASE_DIR"